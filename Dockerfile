FROM node:18

LABEL org.opencontainers.image.authors="grass<467195537@qq.com>"
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm

ENV LINK_NOTE_VERSION 0.0.1

WORKDIR /link-note


COPY ./dist/.npmrc /link-note/
COPY ./dist/pnpm-lock.yaml /link-note/
RUN pnpm fetch --prod

COPY ./dist /link-note

WORKDIR /link-note
RUN pnpm install --prod

CMD pnpm run start:prod

VOLUME [ "/link-note/config", "/link-note/data"]
EXPOSE 4000
