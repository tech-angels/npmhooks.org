npmhooks.org
============

Project to add Rubygem-like webhooks to NPM.

## Requirements

- Redis

## Application configs

The `application.yml` file must be configured as follows (sample [here](https://github.com/cjoudrey/npmhooks.org/blob/master/config/application.example.yml)):

- `SECRET_TOKEN`: The application's `config.secret_token`. This is for Rails signed cookies.
- `NPM_DATABASE_URL`: The url to access NPM's CouchDB.
- `REDIS_HOST` and `REDIS_PORT`: The host and port of the Redis server.
- `GITHUB_KEY` and `GITHUB_SECRET`: The GitHub application credentials that are used for OAuth.