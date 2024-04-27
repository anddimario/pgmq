startup:
  docker run -d --name test_pgmq -e POSTGRES_PASSWORD=postgres -p 5432:5432 quay.io/tembo/pgmq-pg:latest
  sleep 2
  docker exec -it test_pgmq psql -c "CREATE EXTENSION pgmq;"

test:
  crystal spec

cleanup:
  docker stop test_pgmq
  docker rm test_pgmq
