FROM tomcat:9.0-jdk17
WORKDIR /usr/local/tomcat/webapps/
COPY ./target/javaproject-1.0-SNAPSHOT.war ROOT.war
RUN chmod 777 /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
