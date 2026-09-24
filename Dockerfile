FROM alpine:latest

RUN apk add --no-cache curl bash ca-certificates \
    && curl -sL https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz | gzip -d > /usr/local/bin/chisel \
    && chmod +x /usr/local/bin/chisel \
    && curl -L -o /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

EXPOSE 8080 3000

RUN echo '#!/bin/bash' > /entrypoint.sh \
    && echo 'PORT="${PORT:-8080}"' >> /entrypoint.sh \
    && echo 'chisel server --port "$PORT" --reverse &' >> /entrypoint.sh \
    && echo 'if [ -n "$CLOUDFLARE_TOKEN" ]; then' >> /entrypoint.sh \
    && echo ' cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARE_TOKEN"' >> /entrypoint.sh \
    && echo 'else' >> /entrypoint.sh \
    && echo ' wait' >> /entrypoint.sh \
    && echo 'fi' >> /entrypoint.sh \
    && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
