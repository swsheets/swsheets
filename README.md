# EdgeBuilder

EdgeBuilder is a simple application for creating, storing, sharing, and printing Edge of the Empire characters online. It is not intended to enforce any rules of character building or provide any aids beyond calculating die rolls.

## Planned Features

* CRUD a character
* Print a character
* “Play mode” - a live saving mode where you can only edit current wounds, strain, and conditions
* “GM mode” - combine a list of characters to view key stats & skills.

## Setup

EdgeBuilder was built against Elixir 1.0.2, Erlang 17.3, and PostgreSQL 9.3. Once you have all three installed, do the following to set up the app:

```
> mix deps.get
```

Once Mix has fetched all dependencies, you'll need to set up the database. An easy way to do this for local development follows (this approach is not recommended for production).

```
> createuser pair -d
> mix ecto.create
> mix ecto.migrate
> mix seed
```

## Running

To run EdgeBuilder, type `mix phoenix.server`.

Now you can visit `localhost:4000` from your browser.

## Testing
To set up the test database, you'll need to run through the following steps in your commandline, similar to the initial setup
```
> MIX_ENV=test mix ecto.create
> MIX_ENV=test mix ecto.migrate
> MIX_ENV=test mix seed
```

To run the test suite, type `mix test`.

## License

All work within this repo is released under a [Creative Commons Attribution-NonCommercial 3.0 United States](https://creativecommons.org/licenses/by-nc/3.0/us/) license. Essentially you are welcome to do what you like with this as long as you provide attribution and don't charge for it.

Star Wars, Edge of the Empire, and all associated works remain the copyright of their respective copyright holders.
