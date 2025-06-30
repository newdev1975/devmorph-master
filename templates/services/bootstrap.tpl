# Bootstrap CSS Service for DevMorph Studio
# This service handles Bootstrap CSS/JS compilation and customization

services:
  bootstrap:
    image: node:18-alpine
    user: "1000:1000"
    working_dir: /app
    command: >
      sh -c "
        npm install bootstrap @popperjs/core &&
        cp -r node_modules/bootstrap/dist/css/* /app/public/css/ &&
        cp -r node_modules/bootstrap/dist/js/* /app/public/js/ &&
        cp -r node_modules/@popperjs/core/dist/umd/popper.min.js /app/public/js/ &&
        npm install -g sass &&
        sass --watch --style=expanded --source-map /app/assets/scss/custom-bootstrap.scss:/app/public/css/custom-bootstrap.css
      "
    volumes:
      - .:/app
      - bootstrap_cache:/app/node_modules
    environment:
      - NODE_ENV=development
    networks:
      - devmorph

volumes:
  bootstrap_cache:

networks:
  devmorph:
    external: true