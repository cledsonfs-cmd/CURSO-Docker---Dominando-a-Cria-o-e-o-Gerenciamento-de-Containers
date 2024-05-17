FROM maven:3-openjdk-17-slim AS build
ARG MAVEN_PROFILE=dev
COPY ./src /app/src/
COPY ./pom.xml /app
RUN mvn -f ./app/pom.xml clean package -P${MAVEN_PROFILE} -Dmaven.test.skip && chmod +x ./app/target/login-1.0-SNAPSHOT.jar

FROM alpine:3.19.0 AS production

RUN <<EOF 
  apk add --no-cache java-cacerts openjdk17-jdk   
EOF

#FROM ubuntu:22.04 AS production
LABEL authors="99039833"

ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin

WORKDIR /app

EXPOSE 8081

COPY --from=build /app/target/login-1.0-SNAPSHOT.jar ./login.jar

ENTRYPOINT ["java", "-jar", "login.jar"]