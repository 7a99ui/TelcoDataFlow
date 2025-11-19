#!/bin/bash
set -e

echo "🛑 Arrêt de Kafka pour libérer des ressources..."
docker-compose stop kafka1 kafka2 kafka3

echo ""
echo "🚀 Démarrage de Spark Master, Workers et Notebook..."
docker-compose up -d spark-master spark-worker1 spark-worker2 spark-notebook

echo ""
echo "⏳ Attente de 30 secondes pour l'initialisation de Spark..."
sleep 30

echo ""
echo "📊 Statut des services Spark :"
docker-compose ps spark-master spark-worker1 spark-worker2 spark-notebook

echo ""
echo "🎉 Spark prêt à communiquer avec MinIO !"
