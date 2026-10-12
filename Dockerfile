FROM docker.io/library/maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B dependency:go-offline
COPY src ./src
RUN mvn -B clean package -DskipTests

FROM docker.io/library/eclipse-temurin:17-jre-jammy
WORKDIR /app
# Copy the JAR from the 'build' stage
COPY --from=build /app/target/lab2p2026.jar lab2p2026.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","lab2p2026.jar"]
