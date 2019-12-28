# SWSheets

SWSheets is a simple application for creating, storing, sharing, and printing Edge of the Empire characters online. It is not intended to enforce any rules of character building or provide any aids beyond calculating die rolls. It used to be called EdgeBuilder until I couldn't get that domain. I'm not going to rename that in the code anytime soon though.

## Planned Features & Suggestions

Please use the [issues page](https://github.com/swsheets/swsheets/issues)

## Setup

### Docker

The easiest way to get the application up and running locally is with Docker.

- If this is your first time with the application, create and seed the database.
  - **NOTE**: If this is not your first time running the app, this will drop the local development database, so ensure that you want to do that.

```
docker-compose run --rm app setup
```

- Run the application.

```
docker-compose up
```

- If you ever want to run ad-hoc `mix` tasks, use the `mix` helper in the root directory of the project.

```
./mix do thing
```

### Traditional

If you prefer not to use Docker, then you'll need to do some more work to get SWSheets up and running.

- Install Elixir 1.9 and Erlang 22.
- Install PostgreSQL >=9.3.
- Install dependencies.

```
mix deps.get
```

- Set up the database. This is for local development only and is not recommended for production.

```
createuser pair -d
script/dbdo
```

- Run the Phoenix server.

```
mix phx.server
```

- Visit `localhost:4000` from your browser.

## Deploying

I use [ansible-swsheets](https://github.com/swsheets/ansible-swsheets). You could probably use Heroku too though.

## Testing

If you have run `script/dbdo` then you're ready to test with

```
mix test
```

## License

All work within this repo is released under a [Creative Commons Attribution-NonCommercial 3.0 United States](https://creativecommons.org/licenses/by-nc/3.0/us/) license. Essentially you are welcome to do what you like with this as long as you provide attribution and don't charge for it.

Star Wars, Edge of the Empire, and all associated works remain the copyright of their respective copyright holders.

Artwork from "[Star Wars Sketch Cards Cantina](http://antonvandort.deviantart.com/art/Star-Wars-Sketch-Cards-Cantina-110607962)" by antonvandort is included under its original [CC BY-NC ND](http://creativecommons.org/licenses/by-nc-nd/3.0/) license.
