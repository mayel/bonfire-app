.PHONY: setup updates db-reset build dev shell

LIBS_PATH=./forks/
ORG_NAME=bonfirenetworks
APP_FLAVOUR=main
APP_NAME=bonfire-$(APP_FLAVOUR)
UID := $(shell id -u)
GID := $(shell id -g)
APP_REL_CONTAINER="$(ORG_NAME)_$(APP_NAME)_release"
APP_REL_DOCKERCOMPOSE=docker-compose.yml
APP_DOCKER_REPO="$(ORG_NAME)/$(APP_NAME)"

export UID
export GID

init:
	@echo "Light that fire... "
	@mkdir -p config/prod
	@cp -n config/templates/public.env config/prod/ | true
	@cp -n config/templates/not_secret.env config/prod/secrets.env | true
	@mkdir -p data/uploads/

help: init
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	
rel-pull: init docker-stop-web ## Run the app in Docker & starts a new `iex` console
	@docker-compose -p $(APP_REL_CONTAINER) -f $(APP_REL_DOCKERCOMPOSE) pull

rel-run: init docker-stop-web ## Run the app in Docker & starts a new `iex` console
	@docker-compose -p $(APP_REL_CONTAINER) -f $(APP_REL_DOCKERCOMPOSE) run --name bonfire_web --service-ports --rm backend bin/bonfire start_iex

rel-run-bg: init docker-stop-web ## Run the app in Docker, and keep running in the background
	@docker-compose -p $(APP_REL_CONTAINER) -f $(APP_REL_DOCKERCOMPOSE) up -d

rel-stop: ## Run the app in Docker, and keep running in the background
	@docker-compose -p $(APP_REL_CONTAINER) -f $(APP_REL_DOCKERCOMPOSE) stop

rel-shell: docker-stop-web ## Runs a simple shell inside of the container, useful to explore the image
	@docker-compose -p $(APP_REL_CONTAINER) -f $(APP_REL_DOCKERCOMPOSE) run --name bonfire_web --service-ports --rm backend /bin/bash