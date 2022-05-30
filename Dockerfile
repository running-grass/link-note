FROM node:18.2 as build

# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm
# RUN apk add python3 make

WORKDIR /build
COPY .npmrc /build/

COPY pnpm-workspace.yaml /build/
# COPY package.json /build/
COPY pnpm-lock.yaml /build/

COPY packages/frontend/package.json /build/packages/frontend/
COPY packages/backend/package.json /build/packages/backend/


WORKDIR /build
RUN pnpm i



COPY . /build/
RUN make build

RUN cp -r /build/dist /link-note
WORKDIR /link-note

RUN pnpm i --prod

# 第二阶段
FROM node:18.2-alpine3.15
LABEL org.opencontainers.image.authors="grass<467195537@qq.com>"
VOLUME [ "/link-note/config", "/link-note/data"]
EXPOSE 4000
WORKDIR /link-note
CMD npm run start:prod


ENV LINK_NOTE_VERSION 0.0.1
COPY --from=build /link-note /link-note