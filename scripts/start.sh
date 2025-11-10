#!/bin/bash
# Script de inicio rápido para el API Gateway con WAF, OpenTelemetry y HTTPS

set -e

echo "🚀 Iniciando API Gateway con WAF, OpenTelemetry y HTTPS..."
echo ""

# Verificar que Docker está ejecutándose
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker no está ejecutándose"
    exit 1
fi

# Verificar que los certificados SSL existen
if [ ! -f "certs/server.key" ] || [ ! -f "certs/server.crt" ]; then
    echo "⚠️  Certificados SSL no encontrados. Generando..."
    ./scripts/generate-certs.sh
fi

# Crear directorios necesarios
mkdir -p nginx/logs
mkdir -p certs

# Construir e iniciar servicios
echo "📦 Construyendo e iniciando servicios..."
docker-compose up -d --build

echo ""
echo "⏳ Esperando a que los servicios estén listos..."
sleep 10

# Verificar estado de los servicios
echo ""
echo "📊 Estado de los servicios:"
docker-compose ps

echo ""
echo "✅ Servicios iniciados!"
echo ""
echo "🔗 URLs disponibles:"
echo "   - API Gateway (HTTPS): https://localhost:8443"
echo "   - Health Check: https://localhost:8443/health"
echo "   - Jaeger UI: http://localhost:16686"
echo "   - Métricas Prometheus: http://localhost:8889/metrics"
echo ""
echo "📝 Ver logs:"
echo "   docker-compose logs -f"
echo ""
echo "🛑 Detener servicios:"
echo "   docker-compose down"
echo ""

