FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY . .

RUN ./gradlew clean bootJar --no-daemon

EXPOSE 8080

CMD ["java", "-jar", "build/libs/app.jar"]
