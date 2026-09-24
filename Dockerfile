FROM alpine:latest

RUN apk add --no-cache curl bash ca-certificates \
    && curl -L https://github.com/go-gost/gost/releases/download/v3.0.0-rc10/gost_3.0.0-rc10_linux_amd64.tar.gz | tar -xz -C /usr/local/bin/ \
    && chmod +x /usr/local/bin/gost \
    && curl -L -o /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

EXPOSE 8080 3000

RUN echo '#!/bin/bash' > /entrypoint.sh \
    && echo 'gost -L "ws://:8080" &' >> /entrypoint.sh \
    && echo 'if [ -n "$CLOUDFLARE_TOKEN" ]; then' >> /entrypoint.sh \
    && echo ' cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARE_TOKEN"' >> /entrypoint.sh \
    && echo 'else' >> /entrypoint.sh \
    && echo ' wait' >> /entrypoint.sh \
    && echo 'fi' >> /entrypoint.sh \
    && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

