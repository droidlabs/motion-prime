# -*- coding: utf-8 -*-
require "bundler/gem_tasks"
namespace :gem do
  task :release do
    helper = Bundler::GemHelper.new
    helper.release_gem(helper.send :built_gem_path)
  end
end

$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require "rubygems"
require "bundler"
require 'motion-cocoapods'
Bundler.setup
Bundler.require
require 'motion-support'
require 'motion-prime'
require 'motion-stump'
require 'motion-redgreen'

Motion::Project::App.setup do |app|
  app.name = 'MotionPrime'
  app.pods do
    pod 'PKRevealController'
    pod 'NanoStore', '~> 2.7.7'
    pod 'SDWebImage'
    pod 'SVPullToRefresh'
    pod 'MBAlertView'
  end
end
