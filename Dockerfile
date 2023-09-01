FROM maven:3.6.0-jdk-11-slim AS package

RUN apt-get update && apt-get install -y \
    curl \
    jq

RUN mkdir -p /app
WORKDIR /app

COPY pom.xml                          .
COPY run.sh                   .
RUN mvn -e -B dependency:resolve

COPY src                              ./src
RUN mvn verify --fail-never -DskipTests

WORKDIR /app/

ENTRYPOINT ["/bin/sh"]
CMD ["run.sh"]

FROM fabric8/java-alpine-openjdk11-jre AS testrun
RUN apk add curl jq

RUN mkdir -p /jar
WORKDIR /jar/

COPY --from=package /app/target/selenium-docker.jar              .
COPY --from=package /app/target/selenium-docker-tests.jar        .
COPY --from=package /app/target/libs                        ./libs
ADD healthcheck.sh                      healthcheck.sh
COPY src/test/resources                                     ./src/test/resources
COPY run.sh                                                 .

WORKDIR /jar/


ENTRYPOINT ["/bin/sh"]
CMD ["healthcheck.sh"]





