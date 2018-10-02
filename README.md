docker run -ti -v $(pwd):/root/src ssarioglu/sonar_scanner sonar_scanner \
  -Dsonar.host.url=http://sonarqube:9000 \
  -Dsonar.projectKey=MyProjectKey \
  -Dsonar.projectName="My Project Name" \
  -Dsonar.projectBaseDir=. \
  -Dsonar.sources=.
