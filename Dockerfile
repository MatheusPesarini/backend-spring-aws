# syntax=docker/dockerfile:1

# Build stage
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /workspace
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests dependency:go-offline
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests package

# Runtime stage
FROM eclipse-temurin:17-jre
ENV JAVA_OPTS="-Xms256m -Xmx512m" \
    TZ=UTC
WORKDIR /app
COPY --from=builder /workspace/target/*.jar app.jar
EXPOSE 8080
USER 1000
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]

