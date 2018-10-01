FROM openjdk:8-alpine

LABEL maintainer="Serdar Sarioglu <serdar.sarioglu@mysystem.org>"

WORKDIR /root

RUN set -x &&\
  apk add --no-cache  curl grep sed unzip &&\
  curl --insecure -o ./sonarscanner.zip -L https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip &&\
  unzip sonarscanner.zip &&\
  rm sonarscanner.zip &&\
  rm sonar-scanner-3.0.3.778-linux/jre -rf &&\
#   ensure Sonar uses the provided Java for musl instead of a borked glibc one
  sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /root/sonar-scanner-3.0.3.778-linux/bin/sonar-scanner

ENV SONAR_RUNNER_HOME=/root/sonar-scanner-3.0.3.778-linux
ENV PATH $PATH:/root/sonar-scanner-3.0.3.778-linux/bin

COPY sonar-runner.properties ./sonar-scanner-3.0.3.778-linux/conf/sonar-scanner.properties

# Use bash if you want to run the environment from inside the shell, otherwise use the command that actually runs the underlying stuff
#CMD /bin/bash
CMD sonar-scanner -Dsonar.projectBaseDir=./src
