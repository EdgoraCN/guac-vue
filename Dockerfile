FROM node:8-alpine as builder
WORKDIR /src
COPY . .
RUN npm config set registry https://registry.npm.taobao.org
RUN npm install 
RUN npm run build 
# && rm -fr node_modules && npm install --only=production

FROM halverneus/static-file-server:latest

COPY --from=builder /src/dist  /web
