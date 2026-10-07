#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
(cd "$ROOT/../nexus-frontend" && npm ci && npm run build)
cd "$ROOT/../nexus-backend"
./mvnw clean test
mkdir -p target/classes/static
cp -R "$ROOT/../nexus-frontend/dist/." target/classes/static/
./mvnw package -DskipTests
printf '%s
' 'Ready: nexus-backend/target/nexus-backend-0.0.1-SNAPSHOT.jar'
