# Tailwind CSS Service for DevMorph Studio
# This service handles Tailwind CSS compilation and JIT processing

services:
  tailwind:
    image: node:18-alpine
    user: "1000:1000"
    working_dir: /app
    command: >
      sh -c "
        npm install tailwindcss postcss autoprefixer &&
        npx tailwindcss -i /app/assets/css/input.css -o /app/public/css/output.css --watch
      "
    volumes:
      - .:/app
      - tailwind_cache:/app/node_modules
    environment:
      - NODE_ENV=development
    networks:
      - devmorph

volumes:
  tailwind_cache:

networks:
  devmorph:
    external: true