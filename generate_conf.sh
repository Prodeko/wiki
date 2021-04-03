#!/bin/bash
# Generate config and secrets required to host your own outline server
set -e
shopt -s expand_aliases

if [ "$(uname)" == "Darwin" ]; then
    if ! command -v gsed &> /dev/null
    then
        # https://unix.stackexchange.com/a/131940
        echo "sed commands here are tested only with GNU sed"
        echo "Installing gnu-sed"
        brew install gnu-sed
    else
        alias sed=gsed
    fi
fi

function env_add {
    key=$1
    val=$2
    filename=$3
    echo "${key}=${val}" >> "$filename"
}

function env_replace {
    key=$1
    val=$2
    filename=$3
    # sed -i "0,/name:/{s/${key}=.*/${key}='${val}'/}" $filename
    sed "s|${key}=.*|${key}=${val}|" -i "$filename"
}

function env_delete {
    key=$1
    filename=$2
    sed "/${key}/d" -i env.outline
}

function create_env_files {
    read -rp "Enter hostname [localhost]: " HOST
    HOST=${HOST:-localhost}

    read -rp "Enter http port number [80]: " HTTP_PORT
    HTTP_PORT=${HTTP_PORT:-80}

    if [ "$HTTP_PORT" == 80 ]
    then
        URL="http://${HOST}"
    else
        URL="http://${HOST}:${HTTP_PORT}"
    fi

    sed "s|8888:80|${HTTP_PORT}:80|" -i docker-compose.yml

    # TODO: Allow configuration of portnumber
    read -rp "Enter bucket name to store images [wiki-bucket]: " BUCKET_NAME
    BUCKET_NAME=${BUCKET_NAME:-wiki-bucket}

    # download latest sample env for outline
    wget --quiet https://raw.githubusercontent.com/outline/outline/main/.env.sample -O env.outline

    # add new line
    echo "" >> env.outline

    env_replace URL "$URL" env.outline
    env_add HOST "$HOST" env.outline
    env_add HTTP_PORT "$HTTP_PORT" env.outline

    SECRET_KEY=$(openssl rand -hex 32)
    UTILS_SECRET=$(openssl rand -hex 32)

    env_replace SECRET_KEY "$SECRET_KEY" env.outline
    env_replace UTILS_SECRET "$UTILS_SECRET" env.outline

    env_delete DATABASE_URL
    env_delete DATABASE_URL_TEST
    env_delete REDIS_URL

    env_replace PORT 3000 env.outline
    env_replace FORCE_HTTPS 'false' env.outline

    # Disable SSL for PostgreSQL: https://github.com/outline/outline/issues/1501
    env_add PGSSLMODE disable env.outline

    # Setup datastore
    MINIO_ACCESS_KEY=$(openssl rand -hex 8)
    MINIO_SECRET_KEY=$(openssl rand -hex 32)

    rm -f env.minio
    env_add MINIO_ACCESS_KEY "$MINIO_ACCESS_KEY" env.minio
    env_add MINIO_SECRET_KEY "$MINIO_SECRET_KEY" env.minio
    env_add MINIO_BROWSER off env.minio

    env_replace AWS_ACCESS_KEY_ID "$MINIO_ACCESS_KEY" env.outline
    env_replace AWS_SECRET_ACCESS_KEY "$MINIO_SECRET_KEY" env.outline
    env_replace AWS_S3_UPLOAD_BUCKET_NAME "$BUCKET_NAME" env.outline
    env_replace AWS_S3_UPLOAD_BUCKET_URL "$URL" env.outline
}

function delete_data {
    read -rp "Do you want to delete your database and images [no]: " DELETE_DB
    DELETE_DB=${DELETE_DB:-no};
    if [ "$DELETE_DB" == "yes" ]
    then
		echo "deleting database and images"
		rm -rfv data/pgdata data/minio_root
    fi
}

function init_data_dirs {
	# get url from outline env
	set -o allexport; source env.outline; set +o allexport
	mkdir -p "data/minio_root/${AWS_S3_UPLOAD_BUCKET_NAME}" data/pgdata
}

"$@"
