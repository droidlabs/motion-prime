#!/usr/bin/env sh
sudo chown -R travis ~/Library/RubyMotion
mkdir -p ~/Library/RubyMotion/build
sudo motion update
bundle install
#sudo pod setup
bundle exec rake pod:install
bundle exec rake clean
bundle exec rake spec output=colorized