# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require "rubygems"
require "bundler"
require 'motion-cocoapods'
Bundler.setup
Bundler.require
require 'motion-support'
require 'nano-store'
require 'motion-prime'

Motion::Project::App.setup do |app|
  app.name = 'MotionPrime'
  app.pods do
    pod 'PKRevealController'
    pod 'NanoStore', '~> 2.6.0'
    pod 'SDWebImage'
    pod 'SVPullToRefresh'
    pod 'MBAlertView'
  end
end
