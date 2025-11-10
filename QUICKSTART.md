# 🚀 Inicio Rápido - API Gateway con WAF, OpenTelemetry y HTTPS

## Prerrequisitos

- Docker Desktop (Windows/Mac) o Docker Engine + Docker Compose (Linux)
- OpenSSL instalado

## Pasos Rápidos

### 1. Generar Certificados SSL

**Windows:**
```powershell
.\scripts\generate-certs.ps1
```

**Linux/Mac:**
```bash
chmod +x scripts/generate-certs.sh
./scripts/generate-certs.sh
```

### 2. Iniciar Servicios

**Windows:**
```powershell
.\scripts\start.ps1
```

**Linux/Mac:**
```bash
chmod +x scripts/start.sh
./scripts/start.sh
```

**O manualmente:**
```bash
docker-compose up -d --build
```

### 3. Verificar que Funciona

```bash
# Health check
curl -k https://localhost:8443/health

# Ver logs
docker-compose logs -f

# Ver estado
docker-compose ps
```

## URLs Disponibles

- **API Gateway (HTTPS)**: https://localhost:8443
- **Health Check**: https://localhost:8443/health
- **Jaeger UI (Tracing)**: http://localhost:16686
- **Métricas Prometheus**: http://localhost:8889/metrics

## Servicios Incluidos

1. **API Gateway** (puerto interno 8090)
   - Spring Cloud Gateway
   - OAuth2/JWT con Auth0
   - Rate Limiting con Redis
   - Circuit Breaker

2. **Nginx WAF** (puertos 80, 8443)
   - HTTPS con certificados SSL
   - Headers de seguridad
   - Proxy reverso
   - ModSecurity (opcional)

3. **OpenTelemetry Collector** (puertos 4317, 4318, 8889)
   - Recopila traces, métricas y logs
   - Exporta a Jaeger y Prometheus

4. **Jaeger** (puerto 16686)
   - Visualización de traces
   - Análisis de rendimiento

5. **Redis** (puerto 6379)
   - Rate Limiting
   - Caché

## Comandos Útiles

```bash
# Ver logs
docker-compose logs -f

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v

# Reconstruir un servicio
docker-compose up -d --build api-gateway

# Ver estado
docker-compose ps
```

## Solución de Problemas

### Error: "Certificados no encontrados"
```bash
# Generar certificados
.\scripts\generate-certs.ps1  # Windows
./scripts/generate-certs.sh   # Linux/Mac
```

### Error: "Puerto ya en uso"
```bash
# Verificar qué proceso usa el puerto
netstat -ano | findstr :8443  # Windows
lsof -i :8443                 # Linux/Mac

# Cambiar puerto en docker-compose.yml si es necesario
```

### Error: "Servicio no inicia"
```bash
# Ver logs del servicio
docker-compose logs api-gateway
docker-compose logs nginx-waf

# Verificar conectividad
docker-compose exec api-gateway wget -O- http://redis:6379
```

## Documentación Completa

Para más detalles, ver [README-DEPLOYMENT.md](README-DEPLOYMENT.md)

## Notas

- Los certificados SSL son autofirmados (solo para desarrollo)
- ModSecurity está deshabilitado por defecto (ver README-DEPLOYMENT.md para habilitarlo)
- Las rutas backend deben ajustarse en `application-docker.yml` si los servicios están en Docker

