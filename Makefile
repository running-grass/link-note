#!make

# include .env
# export $(shell sed 's/=.*//' .env)

FRONTEND = packages/frontend
BACKEND = packages/backend

BACKEND_DIST = packages/backend/dist
FRONTEND_DIST = packages/frontend/build

BACKEND_DIST_FRONT_ROOT = frontend-root

OUTPUT = dist

help:
	echo "help me"
install-deps:
	pnpm install

build-backend: install-deps
	cd ${BACKEND} && pnpm run build

build-frontend: install-deps
	cd ${FRONTEND} && pnpm run build

build: build-backend build-frontend
	rm -rf ${OUTPUT}
	mkdir ${OUTPUT}
	cp -r ${BACKEND_DIST} ${OUTPUT}/
	cp -r ${FRONTEND_DIST} ${OUTPUT}/${BACKEND_DIST_FRONT_ROOT}
	cp ${BACKEND}/package.json ${OUTPUT}/
	cp ${BACKEND}/.env ${OUTPUT}/
	cp ./pnpm-lock.yaml ${OUTPUT}/
	cp ./.npmrc ${OUTPUT}/

docker-build: 
	docker build .

docker-build-dev: 
	docker build -t ghcr.io/link-note/link-note:dev	-t leo1992/link-note:dev .
docker-push-dev: docker-build-dev
	docker push ghcr.io/link-note/link-note:dev
	docker push leo1992/link-note:dev

heroku-push: 
	heroku container:push web --app=link-note

heroku-release: heroku-push
	heroku container:release web --app=link-note

# .PHONY: test
# .PHONY: dev
# .PHONY: watch