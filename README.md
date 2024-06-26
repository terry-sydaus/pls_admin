# RSK - Core for PLS Admin

RSK Core is a core app to control multiple stuff. Includes default web app and admin control panel for administrative tasks.  This version is designed in mind to take care of PLS Admin tasks.

## Install

In config folder, copy `prod.sample.py` as `prod.py` and set `SQLALCHEMY_DATABASE_URI` and `SECRET_KEY` values.

Also set the following variables:

### Values for PLS Grabber
- CHAIN_URI: "https://scan.pulsechain.com/api" is the default.
- PLS_PRICE_URI: This is the API from CoinMarketCap.  You need to setup an account and get a token.  Default: "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest?id=11145"
- PLS_PRICE_API_KEY: is the token mentioned above
- WEB3_PROVIDER_URI: Default is "https://rpc.pulsechain.com".
- ADMIN_GRAFANA_URL: This is the URL for your grafana installation. This is designed solely to have a button on the Admin's dashboard to redirect to your site.
- MAX_HEIGHT_CHECK: This is designed for the first time sync.  It's to prevent the sync operation to look until the moment of the creation.  Default is 17530000, but you can set it to your first block height where you had your first PLS transaction.

Also set a correct `docker-compose.yml` file, you can use(copy) `docker-compose.sample.yml`.  Set `TZ` to your current server's timezone, `APP_SETTINGS_MODULE` as `config.prod`.

Assuming you have already a proper *Docker* and *Docker Compose* installation, you can run the application with:

```python
    docker-compose up
```

### Network configuration

There's a special section inside the docker-compose file to configure the network. You can set this at the end of the compose file as follows:

```yaml
networks:
  master_network:
    external: True
```

> This network must be configured previously with the proper subnet and gateway. You can do it with `docker network create -d bridge master_network`. More details [here](https://docs.docker.com/engine/reference/commandline/network_create/)

Once you have a network created and the network declaration inside the compose file, you need to setup the network inside each container definition as follows:

```yaml
version: "3"
services:
  container:
    image: image/name
    restart: always
    networks:           # This is the network configuration
      - master_network  # Name is the same as the one you set at the end
      # - Other_network
      # - A_macvlan_network:
      #     ipv4_address: 192.168.0.100
    environment:
      - ENV_VAR1=VALUE1
    ports:
      - 80:80

# ...
# Other containers, volume configurations, etc
# ...

networks:  # The network declaration as described above.
  master_network:
    external: True
```

## Grafana Dashboard

There's a Grafana dashboard, you can import it from the extras folder. It's designed to work with the PLS grabber, so you need to setup the datasource and the variables as well.

You can find it [here](/extras/validator_performance.json).


## Usage
### First run

It's not the same as `first-sync`. This is to initialize the database and create the admin user.

Once up, initialize the database with:

```bash
docker exec -it adminpls python3 -m flask first-run
docker exec -it adminpls python3 -m flask db init
```

> It will ask you to input **Proceed!** to continue and **y** to confirm. It also will create the admin user(`admin@rskcore.io`) with default password **admin**.

### First sync

Just for the first time, you need to run the first sync. Do it with:

```bash
docker exec -it adminpls python3 -m flask first-sync
```

Once you're done with the first sync operation, you have to enable the cron task to keep the sync up to date.

### Enable/Disable cron task

To enable the cron task, you need to run:

```bash
docker exec -it adminpls enable_cron.sh
```

To disable the cron task, you need to run:

```bash
docker exec -it adminpls disable_cron.sh
```

### Update admin user

If you forgot your admin password, just run:

```bash
docker exec -it ppmcore adminpls -m flask update-admin
```

> Follow the prompts and confirmation for new password.

Next, if on defaults, you can access the web app at:

```bash
http://server:5000/admin
```

## Upgrade

For core upgrades, you can run:

```bash
./restart_core.sh
```

> This is viable assuming you had the project already cloned with git and correct permissions.
> The script will pull the latest changes, build the new image and restart the container.
> It could be also necessary to update the DB Model.

### Model changes

Every other update could require model changes. If you have not initialized the database, run the following command `docker exec -it ppmcore python3 -m flask db init`, otherwise run:

```bash
docker exec -it adminpls python3 -m flask db migrate
```

Once you review the changes, run:

```bash
docker exec -it adminpls python3 -m flask db upgrade
```

Check any error output for possible issue tracking.

## Code quality status

> wip - raskitoma.io
