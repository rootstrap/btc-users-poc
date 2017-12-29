# Ruby template

## Environment setup

    Docker is required to be installed.

Setup local dockerized environment with:

`bin/dock setup`

## Starting the server

The server can be started with:

`docker-compose up`

Or, if the database service is running (`docker-compose up -d db`)

`bin/dock server`

## Migrations

Create a migration using:

`bin/dock generate-migration <name>`

To migrate database:

`bin/dock migrate`

To migrate database to a version:

`bin/dock migrate -M <version>`

To migrate test database:

`bin/dock migrate-test`

## Specs

Run spec suite with:

`bin/dock rspec`

## Heroku deployment

Push to the heroku instance:

`$ heroku git:remote -a <app-name> -r <remote-name>`

Run the migrations:

`$ heroku run --remote=<remote-name> bin/migrate-db`

Create a user:

```
$ heroku run --remote=<remote-name> bundle exec rack-console
> Services::Users::Create.perform(username: '...', password: '...')
```
