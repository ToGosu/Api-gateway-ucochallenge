# Dockerfile para Nginx con HTTPS y WAF (ModSecurity opcional)
FROM nginx:alpine

# Instalar herramientas necesarias
RUN apk add --no-cache \
    wget \
    curl \
    openssl

# Crear directorios necesarios
RUN mkdir -p /var/log/nginx/modsec \
    /etc/nginx/ssl \
    /etc/nginx/modsec/rules

# Copiar configuración de Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar configuración de ModSecurity (si existe, opcional)
COPY modsec/main.conf /etc/nginx/modsec/main.conf 2>/dev/null || echo "# ModSecurity config" > /etc/nginx/modsec/main.conf
COPY modsec/crs-setup.conf /etc/nginx/modsec/crs-setup.conf 2>/dev/null || echo "# CRS setup" > /etc/nginx/modsec/crs-setup.conf

# Crear archivo placeholder para reglas de ModSecurity
RUN touch /etc/nginx/modsec/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf || true

# Exponer puertos
EXPOSE 80 8443

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:80/health || exit 1

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]

