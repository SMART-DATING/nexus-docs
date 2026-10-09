$ErrorActionPreference = 'Stop'
$backend = Join-Path $PSScriptRoot '../nexus-backend'
$frontend = Join-Path $PSScriptRoot '../nexus-frontend'
Push-Location $frontend
try {
  npm.cmd ci
  if ($LASTEXITCODE) { throw 'npm ci failed' }
  npm.cmd run build
  if ($LASTEXITCODE) { throw 'Frontend build failed' }
} finally { Pop-Location }
Push-Location $backend
try {
  & ./scripts/download-model.ps1
  .\mvnw.cmd clean test
  if ($LASTEXITCODE) { throw 'Backend tests failed' }
  New-Item -ItemType Directory -Force -Path 'target/classes/static' | Out-Null
  Copy-Item -Path (Join-Path $frontend 'dist/*') -Destination 'target/classes/static' -Recurse -Force
  .\mvnw.cmd package -DskipTests
  if ($LASTEXITCODE) { throw 'Backend packaging failed' }
  Write-Host 'Ready: nexus-backend/target/nexus-backend-0.0.1-SNAPSHOT.jar'
} finally { Pop-Location }
