FROM openjdk:11
EXPOSE 8080
WORKDIR target/Company-Details-Service.jar
ENTRYPOINT ["java","-jar","/Company-Details-Service.jar"]