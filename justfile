CONTAINER_NAME:='test_pgmq'

startup: cleanup
  docker run -d --name {{CONTAINER_NAME}} -e POSTGRES_PASSWORD=postgres -p 5432:5432 quay.io/tembo/pgmq-pg:latest
  sleep 2
  docker exec -it {{CONTAINER_NAME}} psql -c "CREATE EXTENSION pgmq;"

test:
  crystal spec

cleanup:
  #!/bin/bash
  if [ "$(docker ps -q -f name={{CONTAINER_NAME}})" ]; then
    echo "Container {{CONTAINER_NAME}} is running. Attempting to stop."
    docker stop {{CONTAINER_NAME}}
    docker rm {{CONTAINER_NAME}}
  fi
