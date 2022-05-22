#!make

# include .env
# export $(shell sed 's/=.*//' .env)

FRONTEND = packages/frontend
BACKEND = packages/backend

BACKEND_DIST = packages/backend/dist
FRONTEND_DIST = packages/frontend/build

BACKEND_DIST_FRONT_ROOT = frontend_root

OUTPUT = dist

help:
	echo "help me"

build-backend:
	cd ${BACKEND} && pnpm run build

build-frontend:
	cd ${FRONTEND} && pnpm run build

build: build-backend build-frontend
	rm -rf ${BACKEND_DIST}/${BACKEND_DIST_FRONT_ROOT}
	mv ${FRONTEND_DIST} ${BACKEND_DIST}/${BACKEND_DIST_FRONT_ROOT}
	rm -rf ${OUTPUT}
	mkdir ${OUTPUT}
	cp -r ${BACKEND_DIST} ${OUTPUT}/
	cp ${BACKEND}/package.json ${OUTPUT}/
	cp ${BACKEND}/.env ${OUTPUT}/
	cp ./pnpm-lock.yaml ${OUTPUT}/


# .PHONY: test
# .PHONY: dev
# .PHONY: watch