ARG ELIXIR_VERSION=1.17.1
ARG OTP_VERSION=25.3.2.9
ARG DEBIAN_VERSION=bookworm-20240612-slim
ARG IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"

FROM ${IMAGE}

RUN apt-get update -y \
  && apt-get install -y build-essential postgresql-client git nodejs npm curl \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs

WORKDIR /opt/app

RUN mix local.hex --force && \
  mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get
RUN mix deps.compile

ADD assets/package.json assets/
RUN npm install -g yarn
RUN cd assets && \
    yarn install

COPY . .

ENTRYPOINT ["./docker-entry.sh"]

