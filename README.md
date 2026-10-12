[![CI/CD Pipeline](https://github.com/isaacmgz/lab2p2026/actions/workflows/build.yml/badge.svg)](https://github.com/isaacmgz/lab2p2026/actions/workflows/build.yml)
[![Quality gate status](https://sonarcloud.io/api/project_badges/measure?project=isaacmgz_lab2p2026&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=isaacmgz_lab2p2026)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=isaacmgz_lab2p2026&metric=coverage)](https://sonarcloud.io/summary/new_code?id=isaacmgz_lab2p2026)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=isaacmgz_lab2p2026&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=isaacmgz_lab2p2026)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=isaacmgz_lab2p2026&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=isaacmgz_lab2p2026)
[![Known Vulnerabilities](https://snyk.io/test/github/isaacmgz/lab2p2026/badge.svg)](https://snyk.io/test/github/isaacmgz/lab2p2026)

# lab2p2026

Spring Boot REST API that returns random data generated with Java Faker, delivered through a CI/CD pipeline
(GitHub Actions → SonarCloud → Docker Hub → Render).

**Live service:** `<RENDER_SERVICE_URL>`

## Endpoints

| Method | Path | Response |
|---|---|---|
| GET | `/` | Health check (`HEALTH CHECK OK!`) |
| GET | `/version` | Application version |
| GET | `/nations` | 10 random nations |
| GET | `/currencies` | 20 random currencies |
| GET | `/aviation` | 20 random aircraft/airport/METAR entries |

## Run locally

```shell
./mvnw spring-boot:run          # http://localhost:8080
./mvnw clean verify             # tests + JaCoCo report in target/site/jacoco
./mvnw test -Dtest=TesterApplicationTests#health   # single test
```

With Docker:

```shell
docker build -t lab2p2026 .
docker run -p 8080:8080 lab2p2026
```

The app listens on `$PORT` when set (Render), otherwise on `8080`.

## CI/CD pipeline

Defined in [`.github/workflows/build.yml`](.github/workflows/build.yml):

```
tests → sonar → build (JAR artifact) → docker (push :latest and :<sha>) → deploy (Render + smoke test)
```

- Every push to `main`, `feature/**`, `docs/**` and every PR into `main` runs tests, SonarCloud analysis and the JAR build.
- Only `main` publishes the Docker image and deploys it.
- Branching follows **trunk-based development**: short-lived branches merged into `main` through pull requests.

Required repository configuration:

| Kind | Name | Purpose |
|---|---|---|
| Secret | `SONAR_TOKEN` | SonarCloud analysis |
| Secret | `DOCKER_USERNAME` / `DOCKER_PASSWORD` | Docker Hub push (use an access token) |
| Secret | `RENDER_DEPLOY_HOOK_URL` | Triggers the Render deploy |
| Variable | `RENDER_SERVICE_URL` | Public URL used by the smoke test |

See [`docs/ENTREGA.md`](docs/ENTREGA.md) for the step-by-step setup and execution evidence.
