FROM ghcr.io/cirruslabs/flutter:3.29.3 AS build

WORKDIR /app
COPY . .

RUN flutter config --enable-web
RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

# SPA fallback for Flutter web (routes)
RUN printf "server {\n  listen 8080;\n  server_name _;\n  root /usr/share/nginx/html;\n  index index.html;\n\n  location / {\n    try_files \$uri \$uri/ /index.html;\n  }\n}\n" > /etc/nginx/conf.d/default.conf

EXPOSE 8080

