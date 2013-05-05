# Hermes

Hermes is an IRC bot that annoys people in `#webdevs` (previously
`#forrst-chat`) on Freenode. It was originally written to replace the
"forrstdotcom" bot.

## Features

* uses Cinch, a well developed and documented IRC bot framework
* wide variety of plugins for retrieving URL titles, storing quotes, retrieving
  cat pictures (very important), displaying the weather and so on
* it doesn't leak memory as bad as Skybot does

## Requirements

* Ruby 1.9.3
* Bundler
* a SQL database such as SQLite3, PostgreSQL or MySQL

## Installation & Setup

The first step is to clone this repository:

    $ git://github.com/YorickPeterse/Hermes.git hermes
    $ cd hermes

Once cloned you can install all the dependencies using Bundler:

    $ bundle install

If you don't have Bundler installed you'll have to run `gem install bundler` in
order to install it.

Once installed you should copy the default configuration file(s):

    $ cp config/config.default.rb config/config.rb

Starting the bot can be done by running the following command:

    $ ruby bin/hermes

## License

All the code in this repository is licensed under the MIT license unless stated
otherwise. A copy of this license can be found in the file "LICENSE" in the
root directory of this repository.
