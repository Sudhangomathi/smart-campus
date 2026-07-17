# Build stage using Maven
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
COPY WebContent ./WebContent
RUN mvn clean package

# Deploy stage: All-in-one container with MySQL and Tomcat 9
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install JVM 17, MySQL Server, Wget, and curl
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    mysql-server \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Setup Java home
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Download and install Apache Tomcat 9
ENV TOMCAT_VERSION=9.0.91
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && mv apache-tomcat-${TOMCAT_VERSION} /usr/local/tomcat \
    && rm -f apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Delete default webapps to ensure ROOT.war takes full precedence
RUN rm -rf /usr/local/tomcat/webapps/*

ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

WORKDIR /app
COPY db/schema.sql ./db/schema.sql
COPY --from=build /app/target/SmartCampus.war /usr/local/tomcat/webapps/ROOT.war

# Fix permissions for MySQL directories
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

# Copy the startup wrapper script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expose Tomcat HTTP Port
EXPOSE 8080

# Start script handles starting MySQL, seeding schema, and running Tomcat
CMD ["/usr/local/bin/start.sh"]
