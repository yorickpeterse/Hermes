# Hermes

A simple IRC bot written using Cinch primarily written to replace the dated
"forrstdotcom" bot (based on Skybot) in `#forrst-chat` on the Freenode network.
The bot is capable of showing Google search results, storing quotes, displaying
website titles (along with shortening the URLs) and much more.

## Features

* uses Cinch, a well developed and documented IRC bot framework
* wide variety of plugins for retrieving URL titles, storing quotes, retrieving
  cat pictures (very important), displaying the weather and so on
* a Sinatra API that provides read only access to public data stored in the
  bot's database
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
