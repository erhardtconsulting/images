#!/usr/bin/env bash

# This is most commonly set to the user 'postgres'
export INIT_PG_ROOT_USERNAME=${INIT_PG_ROOT_USERNAME:-postgres}
export INIT_PG_PORT=${INIT_PG_PORT:-5432}

if [[ -z "${INIT_PG_HOST}"          ||
      -z "${INIT_PG_ROOT_PASSWORD}" ||
      -z "${INIT_PG_USERNAME}"      ||
      -z "${INIT_PG_PASSWORD}"      ||
      -z "${INIT_PG_DBNAME}"
]]; then
    printf "\e[1;32m%-6s\e[m\n" "Invalid configuration - missing a required environment variable"
    [[ -z "${INIT_PG_HOST}" ]]          && printf "\e[1;32m%-6s\e[m\n" "INIT_PG_HOST: unset"
    [[ -z "${INIT_PG_ROOT_PASSWORD}" ]] && printf "\e[1;32m%-6s\e[m\n" "INIT_PG_ROOT_PASSWORD: unset"
    [[ -z "${INIT_PG_USERNAME}" ]]      && printf "\e[1;32m%-6s\e[m\n" "INIT_PG_USERNAME: unset"
    [[ -z "${INIT_PG_PASSWORD}" ]]      && printf "\e[1;32m%-6s\e[m\n" "INIT_PG_PASSWORD: unset"
    [[ -z "${INIT_PG_DBNAME}" ]]        && printf "\e[1;32m%-6s\e[m\n" "INIT_PG_DBNAME: unset"
    exit 1
fi

# These env are for the psql CLI
export PGHOST="${INIT_PG_HOST}"
export PGUSER="${INIT_PG_ROOT_USERNAME}"
export PGPASSWORD="${INIT_PG_ROOT_PASSWORD}"
export PGPORT="${INIT_PG_PORT}"

until pg_isready; do
    printf "\e[1;32m%-6s\e[m\n" "Waiting for Host '${PGHOST}' on port '${PGPORT}' ..."
    sleep 1
done

user_exists=$(\
    psql \
        --tuples-only \
        --csv \
        --command "SELECT 1 FROM pg_roles WHERE rolname = '${INIT_PG_USERNAME}'"
)

if [[ -z "${user_exists}" ]]; then
    printf "\e[1;32m%-6s\e[m\n" "Create User ${INIT_PG_USERNAME} ..."
    createuser ${INIT_PG_USER_FLAGS} "${INIT_PG_USERNAME}"
fi

printf "\e[1;32m%-6s\e[m\n" "Update password for user ${INIT_PG_USERNAME} ..."
psql --command "ALTER USER \"${INIT_PG_USERNAME}\" WITH ENCRYPTED PASSWORD '${INIT_PG_PASSWORD}';"

for dbname in ${INIT_PG_DBNAME}; do
    database_exists=$(\
        psql \
            --tuples-only \
            --csv \
            --command "SELECT 1 FROM pg_database WHERE datname = '${dbname}'"
    )
    if [[ -z "${database_exists}" ]]; then
        printf "\e[1;32m%-6s\e[m\n" "Create Database ${dbname} ..."
        createdb --owner "${INIT_PG_USERNAME}" "${dbname}"
        database_init_file="/initdb/${dbname}.sql"
        if [[ -f "${database_init_file}" ]]; then
            printf "\e[1;32m%-6s\e[m\n" "Initialize Database ..."
            psql \
                --dbname "${dbname}" \
                --echo-all \
                --file "${database_init_file}"
        fi
    fi
    printf "\e[1;32m%-6s\e[m\n" "Update User Privileges on Database ..."
    psql --command "GRANT ALL PRIVILEGES ON DATABASE \"${dbname}\" TO \"${INIT_PG_USERNAME}\";"
done