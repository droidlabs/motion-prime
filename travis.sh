#!/usr/bin/env sh

sudo gem install bundler
sudo bundle install
sudo pod install
sudo bundle exec rake clean &&
sudo bundle exec rake spec &&
sudo bundle exec rake clean &&
sudo bundle exec rake spec osx=true