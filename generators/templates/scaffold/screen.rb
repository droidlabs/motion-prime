class <%= @p_class_name %>Screen < ApplicationScreen
  title "<%= @p_title %>"

  # open_screen "<%= @p_name %>#index"
  def index
    set_title "<%= @p_title %>"
    set_navigation_right_button 'New' do
      open_screen "<%= @p_name %>#new"
    end
    set_section :<%= @p_name %>_table
  end

  # open_screen "<%= @p_name %>#show"
  def show
    @model = params[:model]
    set_title "Show <%= @s_title %>"
    set_navigation_back_button 'Back'
    set_navigation_right_button 'Edit' do
      open_screen "<%= @p_name %>#edit", params: { model: @model }
    end
    set_section :<%= @p_name %>_show, model: @model
  end

  # open_screen "<%= @p_name %>#edit"
  def edit
    @model = params[:model]
    set_title "Edit <%= @s_title %>"
    set_navigation_back_button 'Cancel'
    set_section :<%= @p_name %>_form, model: @model
  end

  # open_screen "<%= @p_name %>#new"
  def new
    @model = <%= @s_class_name %>.new
    set_title "New <%= @s_title %>"
    set_navigation_back_button 'Cancel'
    set_section :<%= @p_name %>_form, model: @model
  end

  def on_return
    if action?(:index)
      main_section.reload_data
    end
  end
end