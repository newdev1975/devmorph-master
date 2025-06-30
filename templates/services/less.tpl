# LESS Compilation Service for DevMorph Studio
# This service compiles LESS files to CSS in development and production environments

services:
  less:
    image: node:18-alpine
    user: "1000:1000"
    working_dir: /app
    command: >
      sh -c "
        npm install -g less &&
        lessc --source-map --watch /app/assets/less/main.less /app/public/css/main.css
      "
    volumes:
      - .:/app
      - less_cache:/app/node_modules
    environment:
      - NODE_ENV=development
    networks:
      - devmorph

volumes:
  less_cache:

networks:
  devmorph:
    external: true