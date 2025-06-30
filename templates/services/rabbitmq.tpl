# RabbitMQ Service Template for DevMorph Studio
# This service provides a RabbitMQ instance for message queuing

services:
  rabbitmq:
    image: rabbitmq:3-management-alpine
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER:-guest}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD:-guest}
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
      - ./rabbitmq.config:/etc/rabbitmq/rabbitmq.config
    ports:
      - "${RABBITMQ_PORT:-5672}:5672"
      - "15672:15672"  # Management interface
    networks:
      - devmorph
    restart: unless-stopped

networks:
  devmorph:
    driver: bridge

volumes:
  rabbitmq_data: