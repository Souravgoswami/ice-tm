# Ice-TM
Ice task manager allows you to monitor your system resources using Arduino connected to 128x64 OLED display.

![Preview](https://github.com/Souravgoswami/ice-tm/blob/master/previews/preview.gif)

Sorry, if you like this repo. But pagination is not a good choice.
This repo was created, and I don't feel like deleting it, but this is archived in favour of:

[blink-taskmanager (Arduino)](https://www.github.com/Souravgoswami/blink-taskmanager)

[Blink-TM (Rubygem)](https://www.github.com/Souravgoswami/blink-tm)

## Installation
Ice-taskmanager should be installed on your Arduino.
Your arduino has to be attached with a rit-253 or similar 128x64 OLED display that can utilize the graphics library from Adafruit.

1. Install the [ice-taskmanager](https://github.com/Souravgoswami/ice-taskmanager) on your arduino.
2.  Install this gem on your computer, laptop, raspberry pi, etc. as:

```
$ gem install ice-tm
```

## Usage
Make sure your arduino is connected to your computer.
Although ice-taskmanager is hot pluggable, and ice-tm works fine with that.

Launch ice-taskmanager with `ice-tm` command on your PC.

## Development
After checking out the repo, run `bin/setup` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/Souravgoswami/ice-tm.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ice::Tm project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ice-tm/blob/master/CODE_OF_CONDUCT.md).
