#!/bin/bash

# Lancer Kafka et MinIO en arrière-plan
docker-compose up -d kafka minio

# Attendre que Kafka soit prêt
echo "Attente de Kafka..."
while ! docker exec kafka kafka-topics --bootstrap-server kafka:9092 --list &> /dev/null; do
    sleep 2
done
echo "Kafka prêt."

# Lancer le consumer
docker-compose up -d consumer
echo "Consumer lancé."

# Lancer le producer
docker-compose up -d producer
echo "Producer lancé."

echo "Pipeline complet démarré !"
