FROM apache/spark:3.5.3-python3

# Passer en root pour installer pip et les packages
USER root

RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install delta-spark==3.2.0 boto3

# Repasser à l'utilisateur spark
USER spark

WORKDIR /opt/spark/app
