# ===== BUILD =====
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Copiamos só os arquivos do wrapper primeiro (cache melhor)
COPY gradlew ./
COPY gradle gradle
RUN chmod +x gradlew

COPY build.gradle.kts settings.gradle.kts ./
# Se tiver outros .gradle.kts de módulos, copie também

# Agora copiamos o resto do código
COPY . .

# Builda com o wrapper, sem testes
RUN ./gradlew clean build -x test --no-daemon

# Copia o JAR gerado
RUN mkdir /out && cp build/libs/*.jar /out/app.jar

# ===== RUNTIME =====
FROM eclipse-temurin:17-jre
WORKDIR /app
ENV JAVA_OPTS="-XX:+ExitOnOutOfMemoryError -XX:MaxRAMPercentage=75.0"
ENV PORT=8080
COPY --from=build /out/app.jar /app/app.jar
EXPOSE 8080

ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Dserver.address=0.0.0.0 -Dserver.port=${PORT} -jar /app/app.jar" ]
