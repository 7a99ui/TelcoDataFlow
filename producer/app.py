from kafka import KafkaProducer
import pandas as pd
import json
import time

producer = KafkaProducer(
    bootstrap_servers="kafka:9092",
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

# Chargement du dataset local au container
df = pd.read_csv("data/dataset.csv")

topic = "demo_topic"

for _, row in df.iterrows():
    msg = row.to_dict()
    producer.send(topic, msg)
    print("Message envoyé :", msg)
    time.sleep(0.1)

producer.flush()
