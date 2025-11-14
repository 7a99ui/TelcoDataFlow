from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .appName("DeltaLake-MinIO-Test")
    .getOrCreate()
)

# Configuration (utile si Spark-submit ne les a pas déjà)
hadoop_conf = spark.sparkContext._jsc.hadoopConfiguration()
hadoop_conf.set("fs.s3a.endpoint", "http://minio:9000")
hadoop_conf.set("fs.s3a.access.key", "minio")
hadoop_conf.set("fs.s3a.secret.key", "minio123")
hadoop_conf.set("fs.s3a.path.style.access", "true")
hadoop_conf.set("fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")

# Exemple de petit DataFrame
data = [("Alice", 1), ("Bob", 0), ("Charlie", 1)]
df = spark.createDataFrame(data, ["customer", "churn"])

# Sauvegarde Delta Lake dans MinIO
delta_path = "s3a://telco-churn/delta/churn_data"
df.write.format("delta").mode("overwrite").save(delta_path)

print("✅ Données Delta Lake écrites dans MinIO !")

# Relecture pour vérification
df2 = spark.read.format("delta").load(delta_path)
df2.show()

spark.stop()
