# servers-test

## Setup
```
docker-compose create
docker-compose start pg redis influx
docker-compose run --rm api rake db:setup
docker-compose run --rm api rake db:migrate
docker exec -it influx_db influx setup
organization name: servers
bucket name: servers
docker-compose up

go to https://localhost:8086/
login
go to API Tokens
Generate all access api token
copy token in influx config
```

### influxdb
```
  influx setup
  bucket name: servers
  org name: servers
  copy token in influx config
```

## API endpoints
```
POST /ip 
body {ip: ip}

DELETE /ip
body {ip: ip}

GET /statistic/:ip?start_date=date&end_date=date
```