# postfix-relay

## How to use:

```bash

git clone git@github.com:riosventosalucas/postfix-relay.git

cd postfix-relay
```

Edit docker-compose.yml, and set the environment variable DOMAIN

```yaml
environment:
    - DOMAIN=<your domain here> # This must be a valid domain name like mydomain.com
```

```bash
docker-compose up --build
```