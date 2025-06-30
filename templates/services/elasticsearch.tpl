# Elasticsearch Service Template for DevMorph Studio
# This service provides an Elasticsearch instance for search engine functionality

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - node.name=elasticsearch
      - cluster.name=es-docker-cluster
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
      - xpack.security.enrollment.enabled=false
      - xpack.security.http.ssl.enabled=false
      - xpack.security.transport.ssl.enabled=false
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
      - ./elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
    ports:
      - "${ELASTICSEARCH_PORT:-9200}:9200"
    networks:
      - devmorph
    restart: unless-stopped
    ulimits:
      memlock:
        soft: -1
        hard: -1

networks:
  devmorph:
    driver: bridge

volumes:
  elasticsearch_data: