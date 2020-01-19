# SWSheets

[![CircleCI](https://circleci.com/gh/swsheets/swsheets.svg?style=svg)](https://circleci.com/gh/swsheets/swsheets) [![codecov](https://codecov.io/gh/swsheets/swsheets/branch/master/graph/badge.svg)](https://codecov.io/gh/swsheets/swsheets)

SWSheets is a simple application for creating, storing, sharing, and printing Fantasy Flight Games' Star Wars role-playing game characters online. It is not intended to enforce any rules of character building or provide any aids beyond calculating die rolls.

## Feature Suggestions & Bugs

Please use the [issues page](https://github.com/swsheets/swsheets/issues).

## Setup

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

- If you ever want to run ad-hoc `mix` tasks, you can pass arbitrary `mix` tasks to `docker-compose`.

```
docker-compose run --rm app doa.mixthing
```

- Visit `localhost:4000` from your browser.

## Testing

You can run your tests inside the container with `docker-compose`.

```
docker-compose run --rm app test
```

## License

All work within this repo is released under a [Creative Commons Attribution-NonCommercial 3.0 United States](https://creativecommons.org/licenses/by-nc/3.0/us/) license. Essentially you are welcome to do what you like with this as long as you provide attribution and don't charge for it.

Star Wars, Edge of the Empire, Age of Rebellion, Force and Destiny, and all associated works remain the copyright of their respective copyright holders.

Artwork from "[Star Wars Sketch Cards Cantina](http://antonvandort.deviantart.com/art/Star-Wars-Sketch-Cards-Cantina-110607962)" by antonvandort is included under its original [CC BY-NC ND](http://creativecommons.org/licenses/by-nc-nd/3.0/) license.
