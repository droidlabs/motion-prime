class MotionPrime::ModelGenerator < MotionPrime::Generator
  def generate(name)
    @name = name.downcase.singularize
    @class_name = "#{name.classify}"
    template 'model.rb', "app/models/#{name}.rb"
  end
end