# Multi-stage build for optimized image size
FROM maven:3.9.0-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml
COPY online_voting_system/OnlineVotingSystem/pom.xml .

# Download dependencies
RUN mvn dependency:resolve

# Copy source code
COPY online_voting_system/OnlineVotingSystem/src ./src

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre

WORKDIR /app

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Copy built WAR file from builder
COPY --from=builder /app/target/voting-system.war .

# Copy pom.xml for runtime
COPY online_voting_system/OnlineVotingSystem/pom.xml .

# Download Maven at runtime (needed for cargo:run)
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start command
CMD ["mvn", "cargo:run"]
