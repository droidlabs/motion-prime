require 'motion-require'

Motion::Require.all(Dir.glob(File.expand_path('../../motion-prime/**/*.rb', __FILE__)))

Motion::Project::App.setup do |app|
  app.detect_dependencies = false
  app.fonts = [File.expand_path('../../resources/fonts/ubuntu.ttf', __FILE__)]
end