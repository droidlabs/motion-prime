class MotionPrime::TableGenerator < MotionPrime::Generator
  def generate(name)
    @name = name.downcase.singularize
    @model_class_name = "#{name.camelize}"
    @table_class_name = "#{name.pluralize.camelize}TableSection"
    @cell_class_name = "#{name.pluralize.camelize}CellSection"
    template 'table.rb', "app/sections/#{name.pluralize}/table.rb"
    template 'cell.rb', "app/sections/#{name.pluralize}/cell.rb"
  end
end