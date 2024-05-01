# pgmq

A Crsytal client for [PGMQ](https://github.com/tembo-io/pgmq)

## Features

- Queue: create, archive count, purge, drop, metrics
- Message: send, read, delete, archive, pop

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     pgmq:
       github: anddimario/pgmq
   ```

2. Run `shards install`

## Usage

```crystal
require "pgmq"
```

## Development

Install [just](https://github.com/casey/just)

### Run test

Run: `just startup test cleanup`

## Contributing

1. Fork it (<https://github.com/your-github-user/pgmq/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Andrea Di Mario](https://github.com/anddimario) - creator and maintainer
