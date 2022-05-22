FROM node:18

LABEL org.opencontainers.image.authors="grass<467195537@qq.com>"
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm

ENV LINK_NOTE_VERSION 0.0.1

COPY pnpm-lock.yaml /pnpm/
WORKDIR /pnpm
RUN pnpm fetch


COPY . /build/
WORKDIR /build
RUN pnpm i
RUN make build

RUN cp -r /build/dist /link-note
WORKDIR /link-note

RUN pnpm i

CMD pnpm run start:prod

VOLUME [ "/link-note/config", "/link-note/data"]
EXPOSE 4000
