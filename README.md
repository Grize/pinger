# servers-test

## Setup

### influxdb
```
  influx setup
  bucket name: servers
  org name: servers
  copy token in influx config
```

### Postgresql
```
  createuser servers_test_dev --createdb
  createdatabase api_service_dev --owner=servers_test_dev
```

### API Service
```
  cd api_service
  bundle install
  rake db:setup
  rake db:migrate
  ruby main.rb
```

## API endpoints
```
POST /ip 
body {ip: ip}

DELETE /ip
body {ip: ip}

GET /statistic/:ip?start_date=date&end_date=date
```

### Daemon Service
```
  cd ping_service
  bundle install
  ruby daemon_controller.rb run
```

