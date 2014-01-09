require 'motion-require'
require File.expand_path('../../motion-prime/env.rb', __FILE__)
require File.expand_path('../../motion-prime/prime.rb', __FILE__)

Motion::Require.all(Dir.glob(File.expand_path('../../motion-prime/**/*.rb', __FILE__)))

Motion::Project::App.setup do |app|
  app.detect_dependencies = false

  app.pods do
    pod 'NanoStore', '~> 2.7.7'
    pod 'SDWebImage'
    pod 'SVPullToRefresh'
    pod 'MBAlertView'
    pod 'SDSegmentedControl'
    pod 'MBProgressHUD'
  end
end