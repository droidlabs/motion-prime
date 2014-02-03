# ** What is a TableSection? **
#
# "TableSection" is a "Section" which have some sugar to work with UITableViews.

# ** Create a Cell Section. **
#
# Inherit it from `Prime::Section`. 
# 
# Each element inside this section will be part of one cell.

class FooCellSection < Prime::Section
  element :title, text: proc { model[:title] }
end

# ** Create a Table Section. **
#
# Just inherit it from `Prime::TableSection`. 
#
# The key method which should be created is `table_data`. It should return array of any sections.

class FooTableSection < Prime::TableSection
  def table_data
    my_foo_items.map do |fruit_name|
      model = {title: fruit_name}
      FooCellSection.new(model: model)
    end
  end

  def my_foo_items
    %w[Orange Apricot Banana]
  end
end

# ** Render table to a Screen. **
#

class FooScreen < Prime::Screen
  def render
    @main_section = FooTableSection.new(screen: self)
    @main_section.render
  end
end

# ** Style it. **
#
# Of course, don't forget to add styles for table cells.

Prime::Styles.define :foo_cell do
  style :title,
    left: 20,
    top: 5,
    width: 200,
    height: 20
end