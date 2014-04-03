# Logginator

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'logginator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logginator

## Usage

### Output data to the console on 2 second intervals

```logginator nginx --flush 2 --tail-command 'tail -F nginx_log_sample.log'```

### Send data directly to graphite

```logginator nginx --flush 10 --tail-command 'tail -F nginx_log_sample.log' --sender tcp --port 2003 --address 192.168.23.202```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/logginator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
