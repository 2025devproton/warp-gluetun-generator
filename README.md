# Gen Warp (Docker Image)

Genera un `wg0.conf` listo para usar con Gluetun, usando Cloudflare WARP y `wgcf`, sin instalar nada en tu máquina. La imagen incluye el script `gen-warp.sh`, `wgcf`, y todas las utilidades necesarias.

---

## 🚀 ¿Qué hace esta imagen?

- Registra automáticamente una cuenta WARP (`wgcf-account.toml`)
- Genera un `wg0.conf` limpio y funcional
- Elimina toda la configuración IPv6
- Corrige `Address`, `DNS` y `AllowedIPs`
- Resuelve el hostname del Endpoint y lo sustituye por la IP real
- Deja el perfil 100% compatible con Gluetun

Todo en un solo comando.

---

## 📦 Construir la imagen

```bash
docker build -t gen-warp .
```

---

## ▶️ Generar el perfil WARP

Crea un directorio llamado `vpn` (o el que quieras) y ejecuta:

```bash
docker run --rm -v "${PWD}/vpn:/app" -w /app gen-warp
```

El comando generará en ese directorio:

- `wg0.conf` → usable directamente por Gluetun
- `wgcf-account.toml` → cuenta WARP necesaria para regenerar el perfil

---

## 🔄 Regenerar usando la misma cuenta WARP

Conserva `wgcf-account.toml` y vuelve a ejecutar el contenedor:

```bash
docker run --rm -v "${PWD}/vpn:/app" -w /app gen-warp
```

Si el archivo está presente, `wgcf` reutilizará la misma cuenta.

---

## 📂 Estructura resultante

```
vpn/
 ├── wg0.conf            # Perfil WireGuard listo para Gluetun
 └── wgcf-account.toml   # Cuenta WARP persistente
```

---

## 🧹 Uso totalmente stateless (cuenta nueva cada vez)

```bash
rm -f vpn/wgcf-account.toml
docker run --rm -v "${PWD}/vpn:/app" -w /app gen-warp
```

---

## 🛠️ Notas técnicas

- Basada en `debian:bookworm-slim`
- Incluye: `wgcf`, bash, ca-certificates, dnsutils (nslookup), awk
- ENTRYPOINT: `gen-warp.sh`
- IPv6 eliminada para máxima compatibilidad
- DNS consolidado en una sola línea
- Endpoint reemplazado por su IP real

---

## 📜 Licencia

The Unlicense
