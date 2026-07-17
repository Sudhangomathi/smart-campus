# Build stage using Maven
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
COPY WebContent ./WebContent
RUN mvn clean package

# Deploy stage using Tomcat 9
FROM tomcat:9.0-jdk17-openjdk
COPY --from=build /app/target/SmartCampus.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
