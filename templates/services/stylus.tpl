# Stylus Compilation Service for DevMorph Studio
# This service compiles Stylus files to CSS in development and production environments

services:
  stylus:
    image: node:18-alpine
    user: "1000:1000"
    working_dir: /app
    command: >
      sh -c "
        npm install -g stylus &&
        stylus --watch --sourcemap-inline --out /app/public/css /app/assets/stylus
      "
    volumes:
      - .:/app
      - stylus_cache:/app/node_modules
    environment:
      - NODE_ENV=development
    networks:
      - devmorph

volumes:
  stylus_cache:

networks:
  devmorph:
    external: true