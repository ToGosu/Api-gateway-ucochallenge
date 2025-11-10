# Script de inicio rápido para el API Gateway con WAF, OpenTelemetry y HTTPS
# PowerShell

Write-Host "🚀 Iniciando API Gateway con WAF, OpenTelemetry y HTTPS..." -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker está ejecutándose
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Error: Docker no está ejecutándose" -ForegroundColor Red
    exit 1
}

# Verificar que los certificados SSL existen
if (-not (Test-Path "certs\server.key") -or -not (Test-Path "certs\server.crt")) {
    Write-Host "⚠️  Certificados SSL no encontrados. Generando..." -ForegroundColor Yellow
    .\scripts\generate-certs.ps1
}

# Crear directorios necesarios
New-Item -ItemType Directory -Force -Path "nginx\logs" | Out-Null
New-Item -ItemType Directory -Force -Path "certs" | Out-Null

# Construir e iniciar servicios
Write-Host "📦 Construyendo e iniciando servicios..." -ForegroundColor Cyan
docker-compose up -d --build

Write-Host ""
Write-Host "⏳ Esperando a que los servicios estén listos..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Verificar estado de los servicios
Write-Host ""
Write-Host "📊 Estado de los servicios:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "✅ Servicios iniciados!" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 URLs disponibles:" -ForegroundColor Cyan
Write-Host "   - API Gateway (HTTPS): https://localhost:8443" -ForegroundColor Gray
Write-Host "   - Health Check: https://localhost:8443/health" -ForegroundColor Gray
Write-Host "   - Jaeger UI: http://localhost:16686" -ForegroundColor Gray
Write-Host "   - Métricas Prometheus: http://localhost:8889/metrics" -ForegroundColor Gray
Write-Host ""
Write-Host "📝 Ver logs:" -ForegroundColor Cyan
Write-Host "   docker-compose logs -f" -ForegroundColor Gray
Write-Host ""
Write-Host "🛑 Detener servicios:" -ForegroundColor Cyan
Write-Host "   docker-compose down" -ForegroundColor Gray
Write-Host ""

