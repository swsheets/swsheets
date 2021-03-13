FROM bitwalker/alpine-elixir-phoenix:1.10.3

RUN apk update && \
    apk add postgresql-client

ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ADD assets/package.json assets/
RUN npm install -g yarn
RUN cd assets && \
    yarn install

COPY . .

EXPOSE 4000

ENTRYPOINT ["./docker-entry.sh"]
