# newrelic-management
## NewRelic Management Utility
* Provides functionality not inherently available through the NewRelic UI

[![Gem Version](http://img.shields.io/gem/v/newrelic-management.svg)][gem]
[![Build Status](http://img.shields.io/travis/bdwyertech/newrelic-management.svg)][travis]
[![Gitter](https://img.shields.io/badge/Gitter-bdwyertech%2Fnewrelic--management-brightgreen.svg)][gitter]
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)][license]

[gem]: https://rubygems.org/gems/newrelic-management
[travis]: http://travis-ci.org/bdwyertech/newrelic-management
[gitter]: https://gitter.im/bdwyertech/newrelic-management
[license]: https://raw.githubusercontent.com/bdwyertech/newrelic-management/master/LICENSE.txt

## Background
The goal here is to allow servers to be added to alert conditions based on tag.  For some reason, NewRelic does not allow much dynamicism in this regard.

Additionally, non-reporting, stale servers can build up in the NewRelic console.  Let's create a programmatic solution to remove servers that haven't reported recently or in X-amount of time.

## Features
* **Adding & Excluding Servers from Alerts, based on:**
  * Tag
  * Server Name
  * Server ID

* **Automatic Removal of Stale, Non-Reporting Servers**

* **Running either of the above functions in a daemonized, periodic fashion, e.g. every 10 minutes.**

## Sample Configuration File
```json
{
  "nr_api_key": "abc123def456",
  "cleanup": true,
  "cleanup_interval": "5m",
  "alert_management_interval": "5m",
  "alerts": [
    {
      "name": "Disk Space",
      "match_any": true,
      "labels": [
        "Environment:Production",
        "Environment:Staging"
      ]
    },
    {
      "name": "RAM Utilization",
      "match_any": true,
      "labels": [
        "Environment:Production",
        "Environment:Staging"
      ],
      "exclude": [
        "Role:Consumers",
        "Role:ETL"
      ]
    },
    {
      "name": "Production - DB",
      "labels": [
        "Environment:Production",
        "Role:Database"
      ]
    }
  ]
}
```

## Security
If daemonizing, you should lock down permissions on all configuration files in this project to only the user which this runs as...

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'newrelic-management'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install newrelic-management

## Usage

    $ newrelic-management -c /path/to/config.json

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bdwyertech/newrelic-management. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
