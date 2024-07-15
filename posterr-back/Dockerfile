FROM elixir:latest

WORKDIR /app

RUN mix local.hex --force

RUN mix local.rebar --force

COPY mix.exs mix.lock ./

RUN mix deps.get

COPY . .
RUN mix do compile

EXPOSE 4000

CMD ["mix", "phx.server"]
