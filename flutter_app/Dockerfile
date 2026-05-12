# Dùng pre-built web output (build bằng Flutter local trước khi docker-compose up)
# Chạy: flutter build web --release --dart-define=API_BASE_URL=
FROM nginx:alpine

# Copy pre-built Flutter web app
COPY build/web /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
