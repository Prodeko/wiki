env.outline env.minio:
	@bash generate_conf.sh create_env_files

.PHONY: clean install start

init-data-dirs: env.outline
	@bash generate_conf.sh init_data_dirs

install: env.outline env.minio init-data-dirs
	@echo "=>run 'make start' and your server should be ready shortly."

start: install
	docker-compose up -d

start-prod:
	docker-compose -f docker-compose.prod.yml up -d

logs:
	docker-compose logs -f

stop:
	docker-compose down || true

clean-docker: stop
	docker-compose rm -fsv || true

clean-conf:
	rm -rf env.*
	rm -rf data/minio_root/.minio.sys/

clean-data:
	@bash generate_conf.sh delete_data

clean: clean-docker clean-conf