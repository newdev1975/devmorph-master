# Bulma CSS Service for DevMorph Studio
# This service handles Bulma CSS compilation and customization

services:
  bulma:
    image: node:18-alpine
    user: "1000:1000"
    working_dir: /app
    command: >
      sh -c "
        npm install bulma &&
        cp -r node_modules/bulma/css/* /app/public/css/ &&
        npm install -g sass &&
        sass --watch --style=expanded --source-map /app/assets/scss/custom-bulma.scss:/app/public/css/custom-bulma.css
      "
    volumes:
      - .:/app
      - bulma_cache:/app/node_modules
    environment:
      - NODE_ENV=development
    networks:
      - devmorph

volumes:
  bulma_cache:

networks:
  devmorph:
    external: true