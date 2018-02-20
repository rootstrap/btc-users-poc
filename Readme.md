# Bitcoin payment processing

A proof of concept for accepting bitcoin payments. It consists on
a bitcoind node for receiving transactions, a worker which queues
the received transactions and link them to the users, and the web
service, which provides the user with an UI for interacting with
the platform.

When a user wants to make a deposit, a new address is created and
presented to them to make the transfer. Once the transfer is sent,
the bitcoind node detects it and queues a job in the worker to get
the transaction details and update the balance.

When a block is created including a transaction, we update the
confirmations number on that transaction, and update the amount
as confirmed (for this example, we only require one confirmation
for marking the transaction complete).

Bitcoind doesn't send additional notifications for new confirmations
on old transactions, so an additional implementation must be done
for incrementing the confirmation on old transactions when a new
block is created (when a transaction has 6 confirmations can be
considered as permanent.)

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
