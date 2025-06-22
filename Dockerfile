###########################################
# ----- Build con maven ----------------- #
###########################################
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY NetBeans/JaguerahaV3/ /app
RUN ls -alh /app/target/
RUN mvn clean package -DskipTests
RUN ls -alh /app/target/

###########################################
# ----- Corriendo tomcat----------------- #
###########################################
#FROM tomcat:9-jdk17 AS tomcat-run
FROM tomcat:10.1 AS tomcat-run

RUN rm -rf /usr/local/tomcat/webapps/*

# COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/Jagueraha.war
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

RUN ls -alh /usr/local/tomcat/webapps/
RUN mkdir -p  /usr/local/tomcat/export/
RUN cp /usr/local/tomcat/webapps/*.war /usr/local/tomcat/export/Jagueraha.war
# COPY --from=builder /app/target/*.war /usr/local/tomcat/export/Jagueraha.war
#COPY Jagueraha3.war /usr/local/tomcat/webapps/Jagueraha.war

# Expose default Tomcat ports (not used to publish but for documentation)
EXPOSE 8080 8005 8009

# Optional: modify configuration, users, or deploy apps
# RUN apt-get update && apt-get install -y vim
RUN ls -alh /usr/local/tomcat/webapps/

# Set default command
CMD ["catalina.sh", "run"]
