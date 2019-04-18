# Header translator for Kong API Gateway

## Description

This plugin takes a request header as input (assuming the header exists), and adds another header for the upstream from a matched db entry, based on the value of the input header.

## Example usage

### Setup

Enabling the plugin:

**POST** http://localhost:8001/plugins

```json
{
	"name": "header-translator",
	"service_id": "...",
	"route_id": "...",
	"config": {
		"input_header_name": "X-Consumer-Username",
		"output_header_name": "X-Target-Upstream"
	}
}
```

Adding a header translation:

**POST** http://localhost:8001/header-dictionary/x-consumer-username/test_consumer/translations/x-target-upstream

```json
{
    "output_header_value": "mockbin.org"
}
```

### Plugin execution on incoming request

Request headers before plugin execution phase:

```json
{
    "Host": "localhost",
    "X-Consumer-Username": "test_consumer"
}
```

Request headers after plugin execution phase:

```json
{
    "Host": "localhost",
    "X-Consumer-Username": "test_consumer",
    "X-Target-Upstream": "mockbin.org"
}
```

## Install
 - clone the git repo
 - add luarock api key to environment variables (LUAROCKS_API_KEY)

## Running tests from project folder:

`make test`

## Publish new release
 - rename rockspec file to the new version
 - change then version and source.tag in rockspec file
 - commit the changes
 - create a new tag (ex.: git tag 0.1.0)
 - push the changes with the tag (git push --tag)
 - `make publish`
 
## Create dummy data on Admin API

- `make dev-env`

## Access local DB

- `make db`