FROM alpine:latest

# Basic dependencies, curl, bash aur cloudflared install karein
RUN apk add --no-cache curl bash ca-certificates \
    && curl -L https://github.com/go-gost/gost/releases/download/v3.0.0-rc10/gost_3.0.0-rc10_linux_amd64.tar.gz | tar -xz -C /usr/local/bin/ \
    && chmod +x /usr/local/bin/gost \
    && curl -L -o /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

# Ports expose karein (Railway WebSocket + Wings HTTP/SFTP)
EXPOSE 8080 2022

# Startup script banayein jo GOST aur Cloudflare dono ko start karegi
RUN echo '#!/bin/bash' > /entrypoint.sh \
    && echo 'gost -L "mwss://:8080" &' >> /entrypoint.sh \
    && echo 'if [ -n "$CLOUDFLARE_TOKEN" ]; then' >> /entrypoint.sh \
    && echo ' cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARE_TOKEN"' >> /entrypoint.sh \
    && echo 'else' >> /entrypoint.sh \
    && echo ' wait' >> /entrypoint.sh \
    && echo 'fi' >> /entrypoint.sh \
    && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
