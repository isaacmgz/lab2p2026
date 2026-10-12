# Lab 2 Deliverable: Cloud Deployment with Trunk-Based CI/CD

Course: Arquitectura de Software, Universidad de Antioquia
Repository: https://github.com/isaacmgz/lab2p2026 (fork of `diegobotia/lab2p2026`)

## 1. Requirements and how they are met

| Requirement | Implementation |
|---|---|
| Connect the pipeline to a cloud provider | **Render** web service running the Docker image published to Docker Hub |
| Deploy the JAR in an application container | `docker` job builds the image that packages `lab2p2026.jar`; `deploy` job tells Render to run that exact image (`:<commit-sha>`) |
| Trunk-based PRs with at least one extra branch, configured in `build.yml` | Short-lived branches `feature/setup-accounts`, `fix/pin-docker-actions`, `feature/cloud-deploy`, `fix/verify-deployed-commit`, `docs/readme` merged into `main` via PRs; `build.yml` triggers on pushes to `feature/**` and `docs/**` and on every PR into `main` |
| Step-by-step and cloud execution evidence | This document and `docs/evidence/` |

## 2. Pipeline

```
push / PR
   │
   ▼
tests ──► sonar ──► build ──► docker ──► deploy
(JUnit)  (SonarCloud  (JAR      (Docker Hub   (Render deploy hook
          + JaCoCo)   artifact)  :latest,:sha)  + smoke test)
                                 └──── only on main ────┘
```

## 3. Step by step

### 3.1 Fork and local verification
1. Forked `diegobotia/lab2p2026` into `isaacmgz/lab2p2026` and enabled GitHub Actions on the fork.
2. Verified the build locally: `./mvnw -B clean verify` (7 original tests passing; 9 after adding `/commit`).
3. Built and ran the container locally, checking `/`, `/version` and `/currencies`.

### 3.2 Adapting the project (`feature/setup-accounts`)
1. SonarCloud project key and organization changed to `isaacmgz_lab2p2026` / `isaacmgz` in `pom.xml`.
2. `server.port=${PORT:8080}` so the app listens on the port Render injects.
3. Dockerfile: fully qualified, pinned base images and a dependency cache layer.
4. `build.yml`: trunk-based triggers, updated actions, official Docker actions, image push only from `main`.

### 3.3 Accounts and secrets
1. **SonarCloud**: imported the repository, disabled *Automatic Analysis*, generated a token and stored it as the `SONAR_TOKEN` secret.
2. **Docker Hub**: created an access token; stored `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets.
3. **Render**:
   - New → Web Service → *Existing image* → `docker.io/isaacmgz/lab2p2026:latest`, Free instance.
   - Settings → Deploy Hook: copied the URL into the `RENDER_DEPLOY_HOOK_URL` secret.
   - Stored the public service URL in the `RENDER_SERVICE_URL` repository variable.
4. **Snyk**: imported the repository to get the vulnerability badge.

### 3.4 Cloud deployment (`feature/cloud-deploy`)
Added the `deploy` job, which:
1. Calls the Render deploy hook with `imgURL=docker.io/isaacmgz/lab2p2026:<sha>`, so Render runs the exact image built for that commit.
2. Polls `/commit` until it returns the SHA of the commit being deployed (baked into the image via the `APP_COMMIT` build-arg), then checks `/` and `/version`. This proves the new version is live, not the previous instance that Render keeps serving during rollout.

### 3.5 Issues found and fixed
| Issue | Cause | Fix |
|---|---|---|
| SonarCloud quality gate failed (security rating C) | Rule `githubactions:S7637`: third-party actions referenced by mutable tag | Pinned `docker/login-action` and `docker/build-push-action` to full commit SHA (PR #2) |
| Docker push `unauthorized: access token has insufficient scopes` | Docker Hub token created as read-only | Regenerated token with Read & Write scope |
| Smoke test passed in <1s without validating the new deploy | Render keeps the previous instance serving during rollout | `/commit` endpoint + smoke test waits for the deployed SHA (PR #4) |

### 3.6 Trunk-based flow
Each change was made on a short-lived branch, validated by the pipeline on its PR (tests, Sonar, build), and merged into `main`, which triggers the image publication and the deployment.

| PR | Branch | Content |
|---|---|---|
| #1 | `feature/setup-accounts` | Accounts, triggers and pipeline modernization |
| #2 | `fix/pin-docker-actions` | Pin third-party actions to commit SHA (fixes SonarCloud security rating) |
| #3 | `feature/cloud-deploy` | Render deployment job |
| #4 | `fix/verify-deployed-commit` | `/commit` endpoint and live-commit smoke test |
| #5 | `docs/readme` | README and this document |

## 4. Execution evidence

Tests against the deployed backend :

```shell
curl https://lab2p2026-latest-dg3g.onrender.com/
curl https://lab2p2026-latest-dg3g.onrender.com/version
curl https://lab2p2026-latest-dg3g.onrender.com/commit
curl https://lab2p2026-latest-dg3g.onrender.com/nations
curl https://lab2p2026-latest-dg3g.onrender.com/currencies
curl https://lab2p2026-latest-dg3g.onrender.com/aviation
```

Screenshots in `docs/evidence/`:

- [ ] GitHub Actions run on `main` with every job green
- [ ] PRs merged into `main`
- [ ] SonarCloud dashboard (quality gate and coverage)
- [ ] Docker Hub repository with `latest` and SHA tags
- [ ] Render service dashboard and deploy log
- [ ] Endpoint responses from the public URL
- [ ] Snyk report
