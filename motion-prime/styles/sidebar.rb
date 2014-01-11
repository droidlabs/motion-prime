Prime::Styles.define :sidebar do
  style :screen,
    background_color: :app_dark

  style :table,
    top: 150,
    left: 0,
    width: 320,
    bottom: 0,
    background_color: :app_dark,
    separator_color: :clear

  style :table_cell,
    selection_style: :none

  style :action_title,
    text_color: :white,
    left: 20,
    top: 10,
    width: 320,
    font: proc { :system.uifont(20) },
    size_to_fit: true
end