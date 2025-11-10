# 🚀 Guía de Despliegue - API Gateway con WAF, OpenTelemetry y HTTPS

Esta guía explica cómo desplegar el API Gateway con WAF (Web Application Firewall), OpenTelemetry y HTTPS usando Docker Compose.

## 📋 Requisitos Previos

- Docker Desktop (Windows/Mac) o Docker Engine + Docker Compose (Linux)
- OpenSSL (para generar certificados SSL)
- Maven (para compilar localmente, opcional)

## 🏗️ Arquitectura

```
Internet → Nginx WAF (HTTPS:8443) → API Gateway (8090) → Microservicios
                              ↓
                      OTEL Collector → Jaeger (Tracing)
```

## 📁 Estructura de Archivos

```
apigateway/
├── Dockerfile                 # Dockerfile para API Gateway
├── docker-compose.yml         # Orquestación de servicios
├── otel-collector-config.yml  # Configuración de OpenTelemetry Collector
├── nginx/                     # Configuración de Nginx WAF
│   ├── Dockerfile
│   ├── nginx.conf
│   └── modsec/               # Configuración de ModSecurity
├── scripts/                   # Scripts de utilidad
│   ├── generate-certs.sh     # Generar certificados (Linux/Mac)
│   └── generate-certs.ps1    # Generar certificados (Windows)
└── certs/                     # Certificados SSL (generados)
```

## 🚀 Pasos de Despliegue

### 1. Generar Certificados SSL

**En Windows (PowerShell):**
```powershell
.\scripts\generate-certs.ps1
```

**En Linux/Mac:**
```bash
chmod +x scripts/generate-certs.sh
./scripts/generate-certs.sh
```

Esto generará los certificados autofirmados en `certs/`:
- `server.key` - Clave privada
- `server.crt` - Certificado

⚠️ **Nota**: Los certificados autofirmados solo son para desarrollo. Los navegadores mostrarán una advertencia de seguridad.

### 2. Crear Directorios Necesarios

```bash
mkdir -p nginx/logs
mkdir -p certs
```

### 3. Construir y Iniciar Servicios

```bash
docker-compose up -d --build
```

Esto construirá e iniciará:
- **API Gateway** (puerto interno 8090)
- **Nginx WAF** (puertos 80 y 8443)
- **OTEL Collector** (puertos 4317, 4318, 8889)
- **Jaeger** (puerto 16686)
- **Redis** (puerto 6379)

### 4. Verificar que los Servicios Estén Funcionando

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f api-gateway
docker-compose logs -f nginx-waf
```

### 5. Probar los Endpoints

**Health Check (HTTP - redirige a HTTPS):**
```bash
curl http://localhost/health
```

**Health Check (HTTPS):**
```bash
curl -k https://localhost:8443/health
```

**API Gateway (HTTPS):**
```bash
curl -k https://localhost:8443/api/v1/cities
```

**Jaeger UI (Tracing):**
```
http://localhost:16686
```

## 🔒 Configuración de WAF (ModSecurity)

⚠️ **NOTA**: Por defecto, el Dockerfile de Nginx usa una configuración **sin ModSecurity** para facilitar el despliegue. ModSecurity requiere compilación adicional y puede causar problemas de dependencias.

### Opción 1: Nginx sin ModSecurity (Recomendado para desarrollo)

El `nginx/Dockerfile` estándar incluye:
- ✅ HTTPS con certificados SSL
- ✅ Headers de seguridad
- ✅ Proxy reverso al API Gateway
- ❌ ModSecurity deshabilitado

### Opción 2: Nginx con ModSecurity (Para producción)

Para habilitar ModSecurity completo:

1. **Usar el Dockerfile alternativo:**
   ```bash
   # En docker-compose.yml, cambiar:
   nginx-waf:
     build:
       context: ./nginx
       dockerfile: Dockerfile.with-modsecurity
   ```

2. **Descomentar la configuración de ModSecurity en `nginx/nginx.conf`:**
   ```nginx
   modsecurity on;
   modsecurity_rules_file /etc/nginx/modsec/main.conf;
   ```

3. **Configurar ModSecurity:**
   - Modo detección: `SecRuleEngine DetectionOnly` (solo registra)
   - Modo bloqueo: `SecRuleEngine On` (bloquea ataques)

### Reglas de ModSecurity

Las reglas básicas están en `nginx/modsec/`:
- `main.conf` - Configuración principal
- `crs-setup.conf` - Configuración de OWASP CRS
- `rules/` - Reglas personalizadas

### Ver Logs de Nginx

```bash
# Ver logs de acceso
docker-compose logs -f nginx-waf

# Ver logs dentro del contenedor
docker-compose exec nginx-waf tail -f /var/log/nginx/access.log
docker-compose exec nginx-waf tail -f /var/log/nginx/error.log
```

### Probar HTTPS y Headers de Seguridad

```bash
# Verificar que HTTPS funciona
curl -k -I https://localhost:8443/health

# Ver headers de seguridad
curl -k -I https://localhost:8443/health | grep -i "strict-transport-security\|x-frame-options\|x-content-type"
```

### Probar WAF (si ModSecurity está habilitado)

```bash
# Probar un ataque SQL Injection (debe ser detectado si ModSecurity está activo)
curl -k "https://localhost:8443/api-gateway/test?id=1' OR '1'='1"

# Ver logs de ModSecurity
docker-compose exec nginx-waf tail -f /var/log/nginx/modsec_audit.log
```

## 📊 OpenTelemetry y Tracing

### Ver Traces en Jaeger

1. Abrir http://localhost:16686 en el navegador
2. Seleccionar el servicio `api-gateway`
3. Hacer clic en "Find Traces"

### Ver Métricas

Las métricas de Prometheus están disponibles en:
```
http://localhost:8889/metrics
```

## 🔧 Configuración de Redis

Redis se usa para Rate Limiting en el API Gateway. Está configurado automáticamente en `docker-compose.yml`.

### Ver Estado de Redis

```bash
docker-compose exec redis redis-cli ping
# Debe responder: PONG
```

### Configuración de Servicios Backend

⚠️ **IMPORTANTE**: Las rutas en `application.yml` están configuradas para `localhost`. Si los servicios backend están en Docker:

1. **Crear un perfil Docker** (ya existe: `application-docker.yml`)
2. **Ajustar las URIs** en `application-docker.yml` según los nombres de los servicios en tu `docker-compose.yml`
3. **Asegurar que los servicios estén en la misma red Docker** (`app-network`)

Ejemplo de ajuste en `application-docker.yml`:
```yaml
- id: user-service-users
  uri: http://nombre-del-servicio:puerto  # Cambiar según tu configuración
```

## 🛠️ Comandos Útiles

### Detener Servicios
```bash
docker-compose down
```

### Detener y Eliminar Volúmenes
```bash
docker-compose down -v
```

### Reconstruir un Servicio Específico
```bash
docker-compose up -d --build api-gateway
```

### Ver Estado de los Servicios
```bash
docker-compose ps
```

### Ver Logs en Tiempo Real
```bash
docker-compose logs -f
```

### Ejecutar Comandos en un Contenedor
```bash
docker-compose exec api-gateway sh
docker-compose exec nginx-waf sh
```

## 🔐 Seguridad en Producción

⚠️ **IMPORTANTE**: Esta configuración es para **desarrollo**. Para producción:

1. **Certificados SSL**: Usar certificados de una CA confiable (Let's Encrypt, etc.)
2. **ModSecurity**: Cambiar a modo bloqueo (`SecRuleEngine On`)
3. **Secrets**: Usar Docker Secrets o variables de entorno seguras
4. **Firewall**: Configurar reglas de firewall apropiadas
5. **Logs**: Configurar rotación de logs
6. **Monitoreo**: Configurar alertas y monitoreo continuo

## 🐛 Solución de Problemas

### Error: "Certificados no encontrados"
```bash
# Verificar que los certificados existen
ls -la certs/
# Deben existir: server.key y server.crt
```

### Error: "Puerto ya en uso"
```bash
# Verificar qué proceso está usando el puerto
netstat -ano | findstr :8443  # Windows
lsof -i :8443                 # Linux/Mac

# Cambiar el puerto en docker-compose.yml si es necesario
```

### Error: "ModSecurity no funciona"
```bash
# Verificar logs de Nginx
docker-compose logs nginx-waf

# Verificar que ModSecurity está instalado
docker-compose exec nginx-waf nginx -V
```

### Error: "OpenTelemetry no envía traces"
```bash
# Verificar que OTEL Collector está funcionando
docker-compose logs otel-collector

# Verificar conectividad
docker-compose exec api-gateway wget -O- http://otel-collector:4317
```

## 📚 Referencias

- [Spring Cloud Gateway](https://spring.io/projects/spring-cloud-gateway)
- [ModSecurity](https://modsecurity.org/)
- [OpenTelemetry](https://opentelemetry.io/)
- [Jaeger](https://www.jaegertracing.io/)
- [Nginx](https://nginx.org/)

## 📝 Notas Adicionales

- Los certificados autofirmados expiran después de 365 días
- ModSecurity está en modo detección por defecto
- Redis se usa para Rate Limiting (configurado en `application.yml`)
- Todos los servicios están en la red `app-network`
- Los logs se almacenan en `nginx/logs/`

## 🤝 Contribuciones

Para contribuir o reportar problemas, por favor crear un issue en el repositorio.

