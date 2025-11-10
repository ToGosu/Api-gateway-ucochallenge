#!/bin/bash
# Script para generar certificados SSL autofirmados para desarrollo
# Uso: ./scripts/generate-certs.sh

set -e

CERT_DIR="certs"
mkdir -p "$CERT_DIR"

echo "🔐 Generando certificados SSL autofirmados..."

# Generar clave privada
openssl genrsa -out "$CERT_DIR/server.key" 2048

# Generar certificado autofirmado válido por 365 días
openssl req -new -x509 -key "$CERT_DIR/server.key" -out "$CERT_DIR/server.crt" \
    -days 365 -subj "/C=CO/ST=Córdoba/L=Montería/O=UCO/CN=localhost"

# Generar certificado para múltiples dominios (SAN)
cat > "$CERT_DIR/server.conf" <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C=CO
ST=Córdoba
L=Montería
O=UCO
CN=localhost

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

# Generar certificado con SAN
openssl req -new -x509 -key "$CERT_DIR/server.key" -out "$CERT_DIR/server.crt" \
    -days 365 -config "$CERT_DIR/server.conf" -extensions v3_req

# Establecer permisos
chmod 600 "$CERT_DIR/server.key"
chmod 644 "$CERT_DIR/server.crt"

echo "✅ Certificados generados en $CERT_DIR/"
echo "   - server.key (clave privada)"
echo "   - server.crt (certificado)"
echo ""
echo "⚠️  NOTA: Estos certificados son autofirmados y solo para desarrollo."
echo "   Los navegadores mostrarán una advertencia de seguridad."

