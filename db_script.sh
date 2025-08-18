psql -p 5410 -h localhost -U postgres -d postgres -c "DROP DATABASE IF EXISTS sapi_development" -c "CREATE DATABASE sapi_development"
cat /Users/rossking/Desktop/PostgreSQL.sql | psql -p 5410 -h localhost -U postgres -d sapi_development
