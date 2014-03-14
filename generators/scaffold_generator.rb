class MotionPrime::ScaffoldGenerator < MotionPrime::Generator
  def generate(name)
    @s_name = name.singularize.downcase
    @p_name = name.pluralize.downcase
    @s_title = @s_name.titleize
    @p_title = @p_name.titleize
    @s_class_name = @s_name.camelize
    @p_class_name = @p_name.camelize
    template 'scaffold/screen.rb', "app/screens/#{@p_name}.rb"
    template 'scaffold/model.rb', "app/models/#{@s_name}.rb"
    template 'scaffold/table.rb', "app/sections/#{@p_name}/table.rb"
    template 'scaffold/cell.rb', "app/sections/#{@p_name}/cell.rb"
    template 'scaffold/form.rb', "app/sections/#{@p_name}/form.rb"
    template 'scaffold/show.rb', "app/sections/#{@p_name}/show.rb"
    template 'scaffold/styles.rb', "app/styles/#{@p_name}.rb"
  end
end