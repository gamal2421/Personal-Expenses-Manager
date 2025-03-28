# Java Web Application with PostgreSQL

## Overview
This project is a Java web application built with JSP and Servlets, using PostgreSQL as the database. The project is deployed on an Apache Tomcat server.
the url for the project : https://personal-production-21dd.up.railway.app/
## Features
- User authentication (Login page)
- Database connection with PostgreSQL
- JSP-based frontend
- Maven for dependency management
- Docker support (if applicable)

## Prerequisites
Ensure you have the following installed:
- Java 17 or later
- Apache Tomcat 9
- PostgreSQL database
- Maven (for dependency management)

## Setup Instructions

### 1️⃣ Clone the Repository
```sh
git clone https://github.com/your-repo/java-web-app.git
cd java-web-app
```

### 2️⃣ Configure Database
Create a PostgreSQL database and user:
```sql
CREATE DATABASE yourdb;
CREATE USER youruser WITH ENCRYPTED PASSWORD 'yourpassword';
GRANT ALL PRIVILEGES ON DATABASE yourdb TO youruser;
```

Update `DBConnection.java` with your database credentials:
```java
String url = "jdbc:postgresql://localhost:5432/yourdb";
String username = "youruser";
String password = "yourpassword";
Connection conn = DriverManager.getConnection(url, username, password);
```

### 3️⃣ Add PostgreSQL JDBC Driver
Ensure your `pom.xml` contains:
```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <version>42.5.4</version>
</dependency>
```
Run:
```sh
mvn clean install
```

### 4️⃣ Deploy to Tomcat
- Copy the `.war` file to Tomcat’s `webapps` directory.
- Start Tomcat:
```sh
catalina.sh run
```

### 5️⃣ Access the Application
Open your browser and navigate to:
```
http://localhost:8080/your-app-name
```

## Troubleshooting
**Issue: PostgreSQL Driver Not Found**
- Ensure `postgresql-xx.x.x.jar` is in `WEB-INF/lib/`.
- Restart Tomcat after adding the dependency.

**Issue: Page Not Updating**
- Clear your browser cache.
- Restart Tomcat and redeploy the WAR file.

## License
This project is licensed under [MIT License](LICENSE).

