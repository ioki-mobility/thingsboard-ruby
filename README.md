# thingsboard-ruby [![CI Status](https://github.com/ioki-mobility/thingsboard-ruby/actions/workflows/main.yml/badge.svg)](https://github.com/ioki-mobility/thingsboard-ruby/actions/workflows/main.yml)

This library helps to integrate the Thingsboard's web-apis (`api` and `device-api`).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'thingsboard-ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install thingsboard-ruby

## Usage
To load this gem run:
```ruby
require 'thingsboard'
```

To perform any Api call:
```ruby
Thingsboard::Api::CreateAsset.call(
  token: '***SECRET_THINGSBOARD_TOKEN***',
  name:  'Bathroom',
  type:  'room',
  label: 'The bathroom next to the entry'
)
```

The response of an Api call usually returns an json-string of the response-body:

```json
      {
        "id": {
            "entityType": "ASSET",
            "id": "332090a0-0737-11eb-b3f7-4dbfb57ed205"
        },
        "createdTime": 1601921922730,
        "additionalInfo": null,
        "tenantId": {
            "entityType": "TENANT",
            "id": "8e71f160-db9a-88ea-95d6-fd59fd7ffce1"
        },
        "customerId": {
            "entityType": "CUSTOMER",
            "id": "13814000-1dd2-11b2-8080-808080808080"
        },
        "name": "Bathroom",
        "type": "room",
        "label": "The bathroom next to the entry"
      }
```

Any request that results in an unexpected error (meaning all response https-status-codes except `2**`) will raise an `Thingsboard::Api::Error`. Depending on the exact kind  of error it will raise different subclasses of `Thingsboard::Api::Error`:

* `Thingsboard::Api::Unauthorized` if http-status is `401`
* `Thingsboard::Api::Forbidden` if http-status is `403`
* `Thingsboard::Api::UnexpectedResponseCode` for any other kind of error (like http-stauts `500`)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ioki-mobility/thingsboard-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
