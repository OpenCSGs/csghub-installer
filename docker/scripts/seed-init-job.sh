#!/bin/bash

set -e

check_server() {
  echo "Waiting CSGHub-Server ready..."
  until /usr/bin/curl -s -o /dev/null ${SERVER_ENDPOINT}/api/v1/tags; do
    sleep 2
  done

  echo "CSGHub-Server is ready."
}

check_casdoor() {
  echo "Waiting Casdoor ready..."
  until /usr/bin/curl -s -o /dev/null ${CASDOOR_ENDPOINT}/api/health; do
    sleep 2
  done

  echo "Casdoor is ready."
}

check_casdoor
check_server

echo "Sleeping 2 seconds to wait for all services done..."
sleep 2

export PGHOST=${POSTGRES_HOST}
export PGPORT=${POSTGRES_PORT}

execute_sql() {
  SQL_COMMAND="$2"
  if [ -z "$SQL_COMMAND" ]; then
    echo "SQL command or script path is required."
    return 1
  fi

  export PGUSER=$1
  export PGPASSWORD=${POSTGRES_SERVER_PASS:-"$PGUSER"}
  export PGDATABASE=${POSTGRES_SERVER_DB:-"$PGUSER"}

  if [ -f "$SQL_COMMAND" ]; then
    /usr/bin/psql -f "$SQL_COMMAND"
  else
    echo "$SQL_COMMAND" | /usr/bin/psql -A -t
  fi
}

init_token() {
  curl -s -o /dev/null -X 'POST' "http://127.0.0.1:8080/api/v1/token/git/init?current_user=$NAME" \
    -H "Authorization: Bearer ${STARHUB_SERVER_API_TOKEN}" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
    "application": "git",
    "name": "init",
    "permission": "write"
  }'
}

get_token() {
  init_token
  curl -s -X 'GET' "http://127.0.0.1:8080/api/v1/user/$NAME/tokens?current_user=$NAME" \
    -H "Authorization: Bearer ${STARHUB_SERVER_API_TOKEN}" \
    -H 'accept: application/json' | jq -r .data[0].token
}

if [ -f "/root/.kube/config" ]; then
  echo "Seed table space_resources..."
  execute_sql "$POSTGRES_SERVER_USER" /etc/server/initialize.sql
else
  execute_sql "$POSTGRES_SERVER_USER" "CREATE OR REPLACE FUNCTION promote_root_to_admin()
       RETURNS TRIGGER AS $$
   BEGIN
       IF NEW.username = 'root' THEN
           UPDATE public.users
           SET role_mask = 'admin'
           WHERE username = 'root';

           -- After update Drop all
           EXECUTE 'DROP TRIGGER IF EXISTS trigger_promote_root_to_admin ON public.users';
           EXECUTE 'DROP FUNCTION IF EXISTS promote_root_to_admin()';
       END IF;

       RETURN NEW;
   END;
   $$ LANGUAGE plpgsql VOLATILE;

   CREATE OR REPLACE TRIGGER trigger_promote_root_to_admin
       AFTER INSERT ON public.users
       FOR EACH ROW
   EXECUTE FUNCTION promote_root_to_admin();"
fi

echo "Create admin user for csghub..."
UUID=""
until [[ -n "$UUID" ]]; do
  UUID=$(execute_sql "$POSTGRES_CASDOOR_USER" "SELECT id FROM public.user WHERE name='root'")
  if [ -z "$UUID" ]; then
    sleep 1
  fi
done
NAME=$(execute_sql "$POSTGRES_CASDOOR_USER" "SELECT name FROM public.user WHERE name='root'")
EMAIL=$(execute_sql "$POSTGRES_CASDOOR_USER" "SELECT email FROM public.user WHERE name='root'")
AVATAR=$(execute_sql "$POSTGRES_CASDOOR_USER" "SELECT avatar FROM public.user WHERE name='root'")

IF_USER_EXISTS=$(execute_sql "$POSTGRES_SERVER_USER" "SELECT COUNT(*) FROM public.users WHERE username='$NAME'")
if [ "$IF_USER_EXISTS" -eq 0 ]; then
  execute_sql "$POSTGRES_SERVER_USER" "INSERT INTO public.users(git_id, name, username, email, password, uuid, reg_provider, role_mask, avatar) VALUES(0, '$NAME', '$NAME', '$EMAIL', ' ', '$UUID', 'casdoor', 'admin', '$AVATAR')"
fi

echo "Create admin namespace for csghub..."
IF_NS_EXISTS=$(execute_sql "$POSTGRES_SERVER_USER" "SELECT COUNT(*) FROM public.namespaces WHERE path='$NAME'")
if [ "$IF_NS_EXISTS" -eq 0 ]; then
  execute_sql "$POSTGRES_SERVER_USER" "INSERT INTO public.namespaces(path, user_id, namespace_type, mirrored) VALUES('$NAME', 1, 'user', 'f')"
fi

cd / && echo "Verify if model demo exists..."
IF_DEMO_EXISTS=$(execute_sql "$POSTGRES_SERVER_USER" "SELECT COUNT(*) from public.repositories WHERE name='tiny-random-Llama-3'")
if [ "$IF_DEMO_EXISTS" -eq 1 ]; then
  echo "Model demo already exists."
else
  echo "Create model demo..."
  curl -X 'POST' "http://127.0.0.1:8080/api/v1/models?current_user=$NAME" \
    -H "Authorization: Bearer ${STARHUB_SERVER_API_TOKEN}" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
          "admin": "root",
          "default_branch": "main",
          "description": "This is a model demo.",
          "license": "MIT",
          "name": "tiny-random-Llama-3",
          "namespace": "root",
          "nickname": "tiny-random-Llama-3",
          "private": false,
          "readme": "A tiny version of meta-llama/Meta-Llama-3-8B-Instruct."
        }'

  echo "Init model data..."
  tar -zxf /etc/server/tiny-random-Llama-3.tar.gz && chown root:root -R /tiny-random-Llama-3 && cd /tiny-random-Llama-3
  git config --global --add safe.directory /tiny-random-Llama-3
  git config url.http://127.0.0.1:8080/.insteadOf ${SERVER_ENDPOINT}
  git remote add origin "http://$NAME:$(get_token)@127.0.0.1:8080/models/$NAME/tiny-random-Llama-3.git"
  git push --set-upstream origin main --force
  rm -rf /tiny-random-Llama-3
fi

cd / && echo "Verify if dataset demo exists..."
IF_DEMO_EXISTS=$(execute_sql "$POSTGRES_SERVER_USER" "SELECT COUNT(*) from public.repositories WHERE name='alpaca-gpt4-data-zh'")
if [ "$IF_DEMO_EXISTS" -eq 1 ]; then
  echo "Dataset demo already exists."
else
  echo "Create dataset demo..."
  curl -X 'POST' "http://127.0.0.1:8080/api/v1/datasets?current_user=$NAME" \
    -H "Authorization: Bearer ${STARHUB_SERVER_API_TOKEN}" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
          "admin": "root",
          "default_branch": "main",
          "description": "This is a dataset demo.",
          "license": "MIT",
          "name": "alpaca-gpt4-data-zh",
          "namespace": "root",
          "nickname": "alpaca-gpt4-data-zh",
          "private": false
        }'

  echo "Init model data..."
  tar -zxf /etc/server/alpaca-gpt4-data-zh.tar.gz && chown root:root -R /alpaca-gpt4-data-zh && cd /alpaca-gpt4-data-zh
  git config --global --add safe.directory /alpaca-gpt4-data-zh
  git config url.http://127.0.0.1:8080/.insteadOf ${SERVER_ENDPOINT}
  git remote add origin "http://$NAME:$(get_token)@127.0.0.1:8080/datasets/$NAME/alpaca-gpt4-data-zh.git"
  git push --set-upstream origin main --force
  rm -rf /alpaca-gpt4-data-zh
fi