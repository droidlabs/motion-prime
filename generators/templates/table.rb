class <%= @table_class_name %> < Prime::TableSection
  def table_data
    # This method should return Array of sections, e.g:
    <%= @model_class_name %>.map do |model|
      <%= @cell_class_name %>.new(model: model)
    end
  end
end