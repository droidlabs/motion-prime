require 'motion-require'
require 'motion-support'
require 'motion-support/core_ext/hash'
require 'sugarcube-common'
require 'bubble-wrap'
require 'bubble-wrap/reactor'
require 'rm-digest'
require 'afmotion'
require File.expand_path('../../motion-prime/env.rb', __FILE__)
require File.expand_path('../../motion-prime/prime.rb', __FILE__)

Motion::Require.all(Dir.glob(File.expand_path('../../motion-prime/**/*.rb', __FILE__)))
Motion::Require.all

Motion::Project::App.setup do |app|
  app.detect_dependencies = false

  app.pods do
    pod 'NanoStore', '~> 2.7.7'
    pod 'SDWebImage'
    pod 'SVPullToRefresh'
    pod 'MBAlertView'
    pod 'MBProgressHUD', '~> 0.8'
  end
end