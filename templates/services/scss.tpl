# SCSS Compilation Service for DevMorph Studio
# This service compiles SCSS files to CSS in development and production environments

services:
  scss:
    image: node:18-alpine
    user: "1000:1000"
    working_dir: /app
    command: >
      sh -c "
        npm install -g sass &&
        sass --watch --style=expanded --source-map /app/assets/scss:/app/public/css
      "
    volumes:
      - .:/app
      - scss_cache:/app/node_modules
    environment:
      - NODE_ENV=development
    networks:
      - devmorph

volumes:
  scss_cache:

networks:
  devmorph:
    external: true