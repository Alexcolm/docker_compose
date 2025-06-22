# Use official Tomcat base image
FROM tomcat:9

RUN rm -rf /usr/local/tomcat/webapps/*
COPY Jagueraha3.war /usr/local/tomcat/webapps/Jagueraha.war

# Expose default Tomcat ports (not used to publish but for documentation)
EXPOSE 8080 8005 8009

# Optional: modify configuration, users, or deploy apps
# RUN apt-get update && apt-get install -y vim

# Set default command
CMD ["catalina.sh", "run"]





