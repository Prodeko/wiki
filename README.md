# Docker compose for outline wiki

Features:

- A simple make and interactive bash script to help you generate all the conf required
- A docker-compose to run your service
- Dummy https certificate generator. Replace with your certificates after generation
- Use minio instead of AWS S3, so that everything is really self-hosted
- nginx reverse proxy for outline and minio

Runs the outline server with https if required

# How to use

Run locally:

```
git clone https://github.com/Prodeko/wiki.git
cd outline-wiki-docker-compose
make start
```

Deploy to production:

- Create an Oauth client in Google Cloud Platform (https://console.cloud.google.com/apis/credentials)
- Configure env variables in https://github.com/Prodeko/infrastructure/tree/master/ansible/roles/ansible-prodeko-services/files/srv/www/wiki
- Deploy by running `ansible-playbook playbook.yml --extra-vars '@passwd.yml' --tags wiki` in the infrastructure repo
