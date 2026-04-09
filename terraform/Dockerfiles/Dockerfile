# Minimal image for ECS (task targets containerPort 3000)
FROM python:3.12-alpine
WORKDIR /srv
RUN printf '<html><body>ok</body></html>' > index.html
EXPOSE 3000
CMD ["python", "-m", "http.server", "3000", "--bind", "0.0.0.0"]
