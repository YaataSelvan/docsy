.RECIPEPREFIX := >
.DEFAULT_GOAL := up

COMPOSE := docker compose

.PHONY: dev prod obs up down logs clean

dev:
>$(COMPOSE) --profile dev up -d --build

prod:
>$(COMPOSE) --profile prod up -d --build

obs:
>$(COMPOSE) --profile obs up -d --build

up:
>$(COMPOSE) up -d --build

down:
>$(COMPOSE) --profile "*" down

logs:
>$(COMPOSE) --profile "*" logs --tail=100 -f

clean:
>$(COMPOSE) --profile "*" down --volumes --remove-orphans
