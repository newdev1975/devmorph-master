# Static Site Template for DevMorph Studio
# This template provides a foundation for static site generators and JAMstack applications

services:
  # Static site generator service (e.g., for Next.js, Gatsby, Hugo, etc.)
  generator:
    build:
      context: .
      dockerfile: Dockerfile.static
    environment:
      - NODE_ENV=production
      - GENERATE_STATIC=true
      - OUTPUT_DIR=/output
    volumes:
      - .:/app
      - static_node_modules:/app/node_modules
      - static_output:/output
    networks:
      - devmorph
    command: npm run build

  # Development server for static site
  dev:
    build:
      context: .
      dockerfile: Dockerfile.static
    environment:
      - NODE_ENV=development
      - GENERATE_STATIC=false
    volumes:
      - .:/app
      - static_node_modules:/app/node_modules
    ports:
      - "${STATIC_PORT:-3000}:3000"
    stdin_open: true
    tty: true
    networks:
      - devmorph
    command: npm run dev

  # Web server to serve the static content
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-80}:80"
      - "${SSL_PORT:-443}:443"
    volumes:
      - static_output:/usr/share/nginx/html:ro
      - ./nginx.static.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - generator
    networks:
      - devmorph

  # Asset optimization service
  optimizer:
    image: node:18-alpine
    working_dir: /app
    command: >
      sh -c "
        npm install -g imagemin-cli svgo &&
        find /assets -name '*.jpg' -o -name '*.png' -o -name '*.svg' | xargs -I {} imagemin {} --out-dir=/optimized &&
        find /assets -name '*.svg' | xargs -I {} svgo {}
      "
    volumes:
      - ./assets:/assets
      - ./optimized:/optimized
    networks:
      - devmorph

  # CDN simulation for development
  cdn:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - static_output:/usr/share/nginx/html
      - ./nginx.cdn.conf:/etc/nginx/nginx.conf
    depends_on:
      - generator
    networks:
      - devmorph

networks:
  devmorph:
    driver: bridge

volumes:
  static_node_modules:
  static_output: