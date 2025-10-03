server {
    #HTTPSblock
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    client_max_body_size 0;

    ssl_certificate /etc/letsencrypt/live/isusanmateo.edu.ph/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/isusanmateo.edu.ph/privkey.pem;

   ####
    root /var/www/the/dist;             # your built frontend location

    # Serve uploaded images at /src/assets/... directly from the filesystem
    location ^~ /src/assets/ {
    proxy_pass         http://127.0.0.1:4000;
    proxy_set_header   Host $host;
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto $scheme;

    # preserve query string (default behavior for proxy_pass when target ends without URI)
    # But if you used proxy_pass http://127.0.0.1:4000/; make sure the trailing slash is set properly.
    # Keep timeouts reasonably high for image processing:
    proxy_connect_timeout 5s;
    proxy_read_timeout 30s;
    proxy_send_timeout 30s;

    # Optional: disable buffering for large uploads (not critical here)
    proxy_buffering off;
    }

    # proxy API requests to Node backend
    location /api/ {
        proxy_pass http://127.0.0.1:4000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location ~ ^/news(/.*)?$ {
        # Proxy only GET requests for meta scraping; pass through other methods unchanged
        proxy_pass http://127.0.0.1:3000$request_uri;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 5s;
        proxy_read_timeout 30s;
        proxy_send_timeout 30s;
        proxy_buffering off;
    }

    # serve the SPA (dist)
    location / {
        try_files $uri $uri/ /index.html;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

   ####


    # Optional health check
    location /healthz { return 200 "ok\n"; add_header Content-Type text/plain; }
}