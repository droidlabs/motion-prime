#!/usr/bin/env sh

bundle install &&
sudo bundle exec rake clean &&
sudo bundle exec rake spec &&
sudo bundle exec rake clean &&
sudo bundle exec rake spec osx=true