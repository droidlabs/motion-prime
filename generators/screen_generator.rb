class MotionPrime::ScreenGenerator < MotionPrime::Generator
  def generate(name)
    @name = name.downcase
    @class_name = "#{name.camelize}Screen"
    @title = name.titleize
    template 'screen.rb', "app/screens/#{name}.rb"
  end
end