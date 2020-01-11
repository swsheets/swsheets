FROM bitwalker/alpine-elixir-phoenix:1.9.2

RUN apk update && \
    apk add postgresql-client

ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ADD assets/package.json assets/
RUN cd assets && \
    npm install

COPY . .

EXPOSE 4000

ENTRYPOINT ["./docker-entry.sh"]
