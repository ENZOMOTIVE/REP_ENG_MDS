FROM eclipse-temurin:23-jdk

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

RUN ./mvnw clean package -P sqlite \
    && mkdir -p /benchbase \
    && tar -xzf target/benchbase-sqlite.tgz \
        --strip-components=1 -C /benchbase

WORKDIR /benchbase
ENTRYPOINT ["java", "-jar", "benchbase.jar"]
