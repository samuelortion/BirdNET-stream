# Setting up the database

There is two database managment systems available: sqlite or mariadb (mysql).

## sqlite

To use sqlite, simply install the sqlite3 package, if it is not already installed on the machine that runs BirdNET-stream.

```bash
sudo apt-get install sqlite3
```

Then fill `config/birdnet.conf` with the proper DATABASE value (you may use any database location):

```bash
DATABASE="./var/db.sqlite"
```

## mariadb

To use mariadb, you need to install the mariadb-server package.

```bash
sudo apt-get install mariadb-server
```

Then, populate the `config/birdnet.conf` file with the proper DATABASE uri:

```bash
DATABASE="mysql://user:password@localhost/birdnet_observations"
```

## Symfony configuration

For both method you need to adapt the file `www/.env.local` to suit your new configuration.

```bash
cd www
# If .env.local does not exists:
cp .env.local.example .env.local
```

```text
# .env.local
# for sqlite (example)
DATABASE_DEFAULT_URL=sqlite:///%kernel.project_dir%/./var/db-default.sqlite
DATABASE_OBSERVATIONS_URL=sqlite:///%kernel.project_dir%/../var/db.sqlite
# for mariadb (example)
DATABASE_DEFAULT_URL=mysql://user:password@localhost/birdnet_default
DATABASE_OBSERVATIONS_URL=mysql://user:password@localhost/birdnet_observations
```

## PHP modules

For symfony to work, make sure you have the required modules according to each method:

- pdo_sqlite
- pdo_mysql