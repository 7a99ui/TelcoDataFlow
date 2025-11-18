
#!/bin/bash
set -e

export CLUSTER_ID=f1a2b3c4-5678-90ab-cdef-1234567890ab
echo "CLUSTER_ID défini : $CLUSTER_ID"

echo "🚀 Démarrage du pipeline complet..."
docker-compose up -d

echo ""
echo "⏳ Attente de 60 secondes pour les health checks..."
sleep 60

echo ""
echo "📋 Création du topic 'demo_topic'..."
docker exec kafka1 kafka-topics \
    --bootstrap-server kafka1:9092 \
    --create \
    --topic demo_topic \
    --partitions 3 \
    --replication-factor 3 2>/dev/null || echo "   Topic existe déjà."

echo ""
echo "📊 Statut des services:"
docker-compose ps

echo ""
echo "🎉 Pipeline HA complet démarré !"


