#!/bin/bash

# Charger le fichier .env si présent
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Vérifier si un argument batch size est fourni, sinon utiliser la variable d'environnement BATCH_SIZE ou 50
BATCH_SIZE=${1:-${BATCH_SIZE:-50}}
echo "Nouvelle taille de batch : $BATCH_SIZE"

# --- Nom du consumer group défini dans consumer/app.py ---
CONSUMER_GROUP="telco_consumer_group"

# --- Arrêter et supprimer tous les containers, volumes et network ---
docker-compose down -v

# --- Démarrer Kafka et MinIO ---
docker-compose up -d kafka minio

# --- Attendre que Kafka soit prêt ---
echo "Attente de Kafka..."
while ! docker exec kafka kafka-topics --bootstrap-server kafka:9092 --list &> /dev/null; do
    sleep 2
done
echo "Kafka prêt."

# --- Attendre que MinIO soit prêt ---
echo "Attente de MinIO..."
until docker exec minio mc alias set local http://minio:9000 minio minio123 &> /dev/null; do
    sleep 2
done
echo "MinIO prêt."

# --- Supprimer les anciens batchs dans MinIO si le bucket existe ---
docker exec minio sh -c "mc ls local/telco-churn &> /dev/null && mc rm --recursive --force local/telco-churn || echo 'Bucket telco-churn inexistant, rien à supprimer.'"
echo "Anciens batchs supprimés si existants."

# --- Réinitialiser les offsets du consumer group ---
docker exec kafka kafka-consumer-groups --bootstrap-server kafka:9092 --group $CONSUMER_GROUP --reset-offsets --all-topics --to-earliest --execute
echo "Offsets du consumer group '$CONSUMER_GROUP' réinitialisés."

# --- Lancer le consumer (la variable BATCH_SIZE sera prise depuis .env ou argument) ---
docker-compose up -d consumer
echo "Consumer lancé avec batch size $BATCH_SIZE."

# --- Lancer le producer ---
docker-compose up -d producer
echo "Producer lancé."

echo "Pipeline relancé avec le dataset depuis le début et batch size personnalisé !"
