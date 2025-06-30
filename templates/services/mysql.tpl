# MySQL Service Template for DevMorph Studio
# This service provides a MySQL database instance

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE:-app}
      MYSQL_USER: ${MYSQL_USER:-user}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD:-password}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-rootpassword}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./initdb:/docker-entrypoint-initdb.d
      - ./my.cnf:/etc/mysql/conf.d/my.cnf
      - ./backups:/backups
    ports:
      - "${MYSQL_PORT:-3306}:3306"
    networks:
      - devmorph
    restart: unless-stopped
    command: >
      --innodb-buffer-pool-size=512M
      --max-connections=200
      --innodb-flush-method=O_DIRECT
      --innodb-log-file-size=64M
      --innodb-thread-concurrency=0
      --innodb-read-io-threads=8
      --innodb-write-io-threads=8
      --max-allowed-packet=64M

networks:
  devmorph:
    driver: bridge

volumes:
  mysql_data: