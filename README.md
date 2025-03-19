# Getting Started

To run the server you'll need Ruby installed at version 3.3.5 or higher, and a local docker installation. For docker you can just visit the [official website](https://www.docker.com/products/docker-desktop/) and choose the correct download for your platform. If you don't have Ruby installed you can use the following instructions:

## Ruby installation

This project manages language installations with asdf. If you don't have it installed, you can pick it up [here](https://asdf-vm.com/guide/getting-started.html). With that installed, next
[install system dependencies](https://github.com/rbenv/ruby-build/wiki#suggested-build-environment) for Ruby.

With that done, you can simply run:

```bash
$ asdf plugin add ruby && asdf plugin add nodejs
```

Now install project dependencies

```bash
$ bundle install
```

## Starting the development server

With those requirements met, you can run the following:

Start the database container:

```sh
$ docker compose up -d
```

or if you want a terminal window attached to the database container just:

```sh
$ docker compose up
```

Then you can start the server:

```sh
$ bundle exec rails s
```
