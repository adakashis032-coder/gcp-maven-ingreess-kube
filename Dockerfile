# Stage 1: Build with Maven
FROM maven:3.8.1-openjdk-17 AS build
WORKDIR /app

# Copy only pom.xml first (better caching)
COPY pom.xml .

# Copy source code (adjust path if nested)
COPY src ./src

# Build the JAR
RUN mvn clean package -DskipTests

# Stage 2: Run with JDK
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy the built JAR from stage 1
COPY --from=build /app/target/*.jar app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

