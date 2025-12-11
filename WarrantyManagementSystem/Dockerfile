# ============================================
# STAGE 1: Build with Maven
# ============================================
FROM maven:3.8-openjdk-11 AS builder

# Set working directory
WORKDIR /app

# Copy pom.xml first for dependency caching
COPY pom.xml .

# Download dependencies (cached)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build WAR
RUN mvn clean package -DskipTests

# ============================================
# STAGE 2: Runtime with Tomcat
# ============================================
FROM tomcat:9.0-jdk11

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from builder stage
COPY --from=builder /app/target/warranty-system.war /usr/local/tomcat/webapps/ROOT.war

# Install unzip (WAR = zip) để bung WAR
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Unpack WAR trước khi run Tomcat
RUN cd /usr/local/tomcat/webapps && \
    unzip ROOT.war -d ROOT && \
    rm ROOT.war

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
