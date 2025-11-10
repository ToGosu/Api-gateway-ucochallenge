# Script PowerShell para generar certificados SSL autofirmados para desarrollo
# Uso: .\scripts\generate-certs.ps1

$CERT_DIR = "certs"

# Crear directorio si no existe
if (-not (Test-Path $CERT_DIR)) {
    New-Item -ItemType Directory -Path $CERT_DIR | Out-Null
}

Write-Host "🔐 Generando certificados SSL autofirmados..." -ForegroundColor Cyan

# Verificar si OpenSSL está disponible
$opensslPath = Get-Command openssl -ErrorAction SilentlyContinue
if (-not $opensslPath) {
    Write-Host "❌ Error: OpenSSL no está instalado." -ForegroundColor Red
    Write-Host "   Instala OpenSSL o usa WSL (Windows Subsystem for Linux)" -ForegroundColor Yellow
    exit 1
}

# Generar clave privada
& openssl genrsa -out "$CERT_DIR\server.key" 2048

# Crear archivo de configuración para SAN (Subject Alternative Names)
$configContent = @"
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
"@

$configContent | Out-File -FilePath "$CERT_DIR\server.conf" -Encoding ASCII

# Generar certificado autofirmado con SAN, válido por 365 días
& openssl req -new -x509 -key "$CERT_DIR\server.key" -out "$CERT_DIR\server.crt" `
    -days 365 -config "$CERT_DIR\server.conf" -extensions v3_req

Write-Host "✅ Certificados generados en $CERT_DIR\" -ForegroundColor Green
Write-Host "   - server.key (clave privada)" -ForegroundColor Gray
Write-Host "   - server.crt (certificado)" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  NOTA: Estos certificados son autofirmados y solo para desarrollo." -ForegroundColor Yellow
Write-Host "   Los navegadores mostrarán una advertencia de seguridad." -ForegroundColor Yellow

