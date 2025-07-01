# Materialize CSS Service for DevMorph Studio
# This service handles Materialize CSS/JS compilation and customization

services:
  materialize:
    image: node:18-alpine
    user: "1000:1000"
    working_dir: /app
    command: >
      sh -c "
        npm install materialize-css &&
        cp -r node_modules/materialize-css/dist/css/* /app/public/css/ &&
        cp -r node_modules/materialize-css/dist/js/* /app/public/js/ &&
        cp -r node_modules/materialize-css/dist/fonts/ /app/public/ &&
        npm install -g sass &&
        sass --watch --style=expanded --source-map /app/assets/scss/custom-materialize.scss:/app/public/css/custom-materialize.css
      "
    volumes:
      - .:/app
      - materialize_cache:/app/node_modules
    environment:
      - NODE_ENV=development
    networks:
      - devmorph

volumes:
  materialize_cache:

networks:
  devmorph:
    external: true