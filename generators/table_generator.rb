class MotionPrime::TableGenerator < MotionPrime::Generator
  def generate(name)
    @name = name.downcase.singularize
    @model_class_name = "#{name.classify}"
    @table_class_name = "#{name.pluralize.classify}TableSection"
    @cell_class_name = "#{name.pluralize.classify}CellSection"
    template 'table.rb', "app/sections/#{name}/table.rb"
    template 'cell.rb', "app/sections/#{name}/cell.rb"
  end
end