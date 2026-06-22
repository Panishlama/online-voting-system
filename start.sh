#!/bin/bash

# Install Maven at runtime
if ! command -v mvn &> /dev/null; then
    echo "📦 Installing Maven..."
    apt-get update
    apt-get install -y maven
fi

# Run the application
echo "🚀 Starting Tomcat 10..."
mvn cargo:run