#!/usr/bin/env bash
set -Eeuo pipefail

OUTDIR="$(pwd)"

run_wgcf() {
  if command -v wgcf >/dev/null 2>&1; then
    wgcf "$@"
  else
    docker run --rm -v "$OUTDIR:/data" -w /data virb3/wgcf "$@"
  fi
}

log() {
  printf '[INFO] %s\n' "$*"
}

error() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

clean_ipv6() {
  local infile="$1"
  local outfile="${infile}.tmp"

  awk '
    BEGIN {
      FS="=";
      OFS=" = ";
    }

    # Limpia Address: solo IPv4, formato "Address = a, b"
    /^Address[[:space:]]*=/ {
      key=$1;
      val=$2;
      gsub(/[[:space:]]/, "", val);
      n = split(val, arr, ",");
      out = "";
      for (i = 1; i <= n; i++) {
        if (index(arr[i], ":") == 0 && arr[i] != "") {
          if (out != "") out = out ", ";
          out = out arr[i];
        }
      }
      print key, out;
      next;
    }

    # Limpia DNS: solo IPv4, formato "DNS = a, b"
    /^DNS[[:space:]]*=/ {
      key=$1;
      val=$2;
      gsub(/[[:space:]]/, "", val);
      n = split(val, arr, ",");
      out = "";
      for (i = 1; i <= n; i++) {
        if (index(arr[i], ":") == 0 && arr[i] != "") {
          if (out != "") out = out ", ";
          out = out arr[i];
        }
      }
      print key, out;
      next;
    }

    # Limpia AllowedIPs: solo IPv4
    /^AllowedIPs[[:space:]]*=/ {
      key=$1;
      val=$2;
      gsub(/[[:space:]]/, "", val);
      n = split(val, arr, ",");
      out = "";
      for (i = 1; i <= n; i++) {
        if (index(arr[i], ":") == 0 && arr[i] != "") {
          if (out != "") out = out ", ";
          out = out arr[i];
        }
      }
      print key, out;
      next;
    }

    # Resto de líneas tal cual
    { print }
  ' "$infile" > "$outfile"

  mv "$outfile" "$infile"
}

log "Registrando cuenta WARP..."
run_wgcf register --accept-tos \
  || error "Falló el registro WARP"

log "Generando perfil WireGuard..."
run_wgcf generate \
  || error "Falló la generación del perfil"

log "Renombrando perfil a wg0.conf..."
mv -f wgcf-profile.conf wg0.conf

log "Limpiando IPv6 (Address, DNS, AllowedIPs) con awk..."
clean_ipv6 wg0.conf

log "Extrayendo hostname del Endpoint..."
HOST="$(grep -E "^Endpoint[[:space:]]*=" wg0.conf | awk -F '=' '{print $2}' | tr -d " " | cut -d':' -f1 || true)"

[[ -z "${HOST:-}" ]] && error "No se pudo extraer el hostname del Endpoint en wg0.conf"

log "Hostname encontrado: $HOST"
log "Resolviendo IP vía nslookup..."

IP="$(nslookup "$HOST" 2>/dev/null | awk "/^Address: /{print \$2; exit}" || true)"

[[ -z "${IP:-}" ]] && error "nslookup falló para $HOST"

log "IP resuelta: $IP"
log "Actualizando endpoint en wg0.conf..."
sed -i "s/$HOST/$IP/" wg0.conf

log "Perfil generado con éxito."

cat <<EOF

============================================
   🎉 wg0.conf LISTO
   📄 $OUTDIR/wg0.conf
   ✔ IPv6 eliminada (Address/DNS/AllowedIPs)
   ✔ DNS en UNA sola línea
   ✔ Endpoint actualizado con IP dinámica
============================================

EOF
