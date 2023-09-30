FROM node:14.20.1-slim as base
ARG PROFILE
WORKDIR /app
COPY . .

FROM base as dependencies
RUN --mount=type=cache,target=node_modules yarn

FROM dependencies as build
ARG build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN --mount=type=cache,target=node_modules yarn run build

FROM nginx:stable
WORKDIR /etc/nginx
RUN rm /etc/nginx/nginx.conf
COPY nginx.conf .
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]


