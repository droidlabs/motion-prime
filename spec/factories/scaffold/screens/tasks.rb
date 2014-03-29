class TasksScreen < Prime::Screen
  title "Tasks"

  # open_screen "tasks#index"
  def index
    set_title "Tasks"
    set_navigation_right_button 'New' do
      open_screen "tasks#new"
    end
    set_section :tasks_index_table
  end

  # open_screen "tasks#show"
  def show
    @model = params[:model]
    set_title "Show Task"
    set_navigation_back_button 'Back'
    set_navigation_right_button 'Edit' do
      open_screen "tasks#edit", params: { model: @model }
    end
    set_section :tasks_show, model: @model
  end

  # open_screen "tasks#edit"
  def edit
    @model = params[:model]
    set_title "Edit Task"
    set_navigation_back_button 'Cancel'
    set_section :tasks_form, model: @model
  end

  # open_screen "tasks#new"
  def new
    @model = Task.new
    set_title "New Task"
    set_navigation_back_button 'Cancel'
    set_section :tasks_form, model: @model
  end

  def on_return
    if action?(:index) || action?(:show)
      refresh
    end
  end
end