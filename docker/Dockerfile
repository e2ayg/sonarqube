# Use the official SonarQube community edition as the base image
FROM sonarqube:9.9.6-community

# Set the maintainer label
LABEL maintainer="your-email@example.com"

# Create necessary directories with correct permissions
USER root
RUN mkdir -p /opt/sonarqube/data /opt/sonarqube/logs /opt/sonarqube/extensions && \
    chown -R sonarqube:sonarqube /opt/sonarqube/data /opt/sonarqube/logs /opt/sonarqube/extensions

# Expose the web port
EXPOSE 9000

# Define volumes to be mounted at container startup
VOLUME ["/opt/sonarqube/data", "/opt/sonarqube/logs", "/opt/sonarqube/extensions"]

# Switch to the non-root user
USER sonarqube
