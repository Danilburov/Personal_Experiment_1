FROM jenkins/jenkins:lts-jdk21

#terraform
COPY --from=hashicorp/terraform:1.16.7 /bin/terraform /usr/local/bin/terraform

#ansible and ssh client
USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends ansible-core openssh-client \
 && rm -rf /var/lib/apt/lists/*
USER jenkins

#plugins as code installed at build time
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

#healtcheck for jenkins inside docker
HEALTHCHECK --start-period=60s CMD curl -fs http://localhost:8080/login || exit 1