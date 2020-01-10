FROM elixir:1.9

RUN apt-get update && \
    apt-get install -y postgresql-client

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

RUN mix local.hex --force && \
    mix local.rebar --force

COPY . .

EXPOSE 4000

ENTRYPOINT ["./docker-entry.sh"]
