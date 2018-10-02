FROM openjdk:8-alpine

ARG MAVEN_DOWNLOAD_URL="http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.zip"
ARG SONAR_SCANNER_DOWNLOAD_URL="https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.2.0.1227-linux.zip"


RUN apk add --no-cache git curl bash grep sed unzip nodejs

# Create install folders
RUN mkdir -p /opt/sonar-scanner
RUN mkdir /opt/apache-maven

# Set timezone to CST
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /opt

# Download SonarScanner and extract it
RUN curl --insecure -o ./sonarscanner.zip -L "${SONAR_SCANNER_DOWNLOAD_URL}" \
    && unzip sonarscanner.zip  \
    && ls -ltr \
    && cp -aR sonar-scanner-3.2.0.1227-linux/* /opt/sonar-scanner \
    && rm -rf sonarscanner.zip sonar-scanner-3.2.0.1227-linux/ \
    && ls -ltr /opt/sonar-scanner

# Download Apache Maven and extract it
RUN curl --insecure -o ./apache-maven.zip -L "${MAVEN_DOWNLOAD_URL}"  \
    && unzip apache-maven.zip \
    && cp -aR apache-maven-3.5.4/* /opt/apache-maven \
    && rm -rf apache-maven.zip apache-maven-3.5.3 \
    && ls -ltr /opt/apache-maven

# Setup home directories and symbolic links
RUN ln -sf "/opt/apache-maven/bin/mvn" "/usr/local/bin/mvn" \
    && ln -sf "/opt/apache-maven/bin/mvnDebug" "/usr/local/bin/mvnDebug"
ENV M2_HOME="/opt/apache-maven"
ENV SONAR_RUNNER_HOME=/opt/sonar-scanner
ENV PATH $PATH:/opt/sonar-scanner/bin

# Add Sonar Maven plugin for Maven projects
RUN mvn -q org.apache.maven.plugins:maven-dependency-plugin:3.0.2:get \
    -DrepoUrl="https://repo.maven.apache.org/maven2/" \
    -Dartifact="org.sonarsource.scanner.maven:sonar-maven-plugin:3.4.0.905:jar"



# Ensure Sonar uses the provided Java for musl instead of a borked glibc one
RUN sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /opt/sonar-scanner/bin/sonar-scanner

COPY sonar-runner.properties ./sonar-scanner/conf/sonar-scanner.properties

# Use bash if you want to run the environment from inside the shell, otherwise use the command that actually runs the underlying stuff
CMD /bin/bash
#CMD sonar-scanner -Dsonar.projectBaseDir=./src
