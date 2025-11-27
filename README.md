# Gen Warp (Docker Image)

[![Docker Pulls](https://img.shields.io/docker/pulls/2025dev/gen-warp.svg)](https://hub.docker.com/r/2025dev/gen-warp)
[![Docker Image Size](https://img.shields.io/docker/image-size/2025dev/gen-warp/latest.svg)](https://hub.docker.com/r/2025dev/gen-warp)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/2025dev/gen-warp/docker-image.yml?branch=main)

Genera un `wg0.conf` listo para usar con Gluetun usando Cloudflare WARP y `wgcf`, sin instalar nada en tu máquina. La imagen incluye el script `gen-warp.sh`, `wgcf` y todas las utilidades necesarias.

---

## 🚀 ¿Qué hace esta imagen?

- Registra automáticamente una cuenta WARP (`wgcf-account.toml`)
- Genera un `wg0.conf` limpio y funcional
- Elimina IPv6 de Address, DNS y AllowedIPs
- Resuelve el hostname del Endpoint y lo sustituye por la IP real
- Genera un perfil **100% compatible con Gluetun**

Todo en un solo comando.

---

## 🐳 Usar la imagen desde Docker Hub (recomendado)

No necesitas clonar el repo ni instalar nada. Ejecuta:

```bash
docker pull 2025dev/gen-warp:latest
```

Genera tu perfil WARP:

```bash
docker run --rm -v "${PWD}/vpn:/app" -w /app 2025dev/gen-warp:latest
```

Esto producirá:

```
vpn/
 ├── wg0.conf            # Perfil WireGuard listo para Gluetun
 └── wgcf-account.toml   # Cuenta WARP persistente
```

---

## 🔄 Regenerar usando la misma cuenta

Si conservas `wgcf-account.toml`, simplemente ejecuta de nuevo:

```bash
docker run --rm -v "${PWD}/vpn:/app" -w /app 2025dev/gen-warp:latest
```

---

## 🧹 Nuevo perfil cada vez (stateless)

Si deseas crear una cuenta WARP nueva cada vez:

```bash
rm -f vpn/wgcf-account.toml
docker run --rm -v "${PWD}/vpn:/app" -w /app 2025dev/gen-warp:latest
```

---

## 🔧 Construir la imagen localmente

```bash
docker build -t gen-warp .
```

Y ejecutarla:

```bash
docker run --rm -v "${PWD}/vpn:/app" -w /app gen-warp
```

---

## 📘 ¿Qué hace internamente el script?

El script `gen-warp.sh`:

1. Registra una cuenta WARP
2. Genera el perfil `wgcf-profile.conf`
3. Lo renombra a `wg0.conf`
4. Elimina todo el contenido IPv6 con `awk`
5. Limpia Address, DNS y AllowedIPs
6. Resuelve el Endpoint con `nslookup` y reemplaza el hostname por la IP
7. Deja el archivo final listo para usar en Gluetun

---

## 📂 Estructura resultante

```
vpn/
 ├── wg0.conf            # Perfil final
 └── wgcf-account.toml   # Cuenta WARP
```

---

## 🛠️ Notas técnicas

- Basado en `debian:bookworm-slim`
- Incluye: `wgcf`, `bash`, `ca-certificates`, `dnsutils` (nslookup) y `awk`
- ENTRYPOINT: `gen-warp.sh`
- Compatible con cualquier plataforma que soporte Docker
