Prime::Styles.define :sidebar do
  style :screen,
    background_color: :clear
  style :table,
    top: 150,
    left: 0,
    width: 320,
    bottom: 0,
    background_color: :clear,
    separator_color: :clear

  style :table_cell,
    selection_style: UITableViewCellSelectionStyleNone

  style :action_title,
    text_color: :white,
    top: 10,
    width: 320,
    font: proc { :system.uifont(20) },
    size_to_fit: true,
    left: 20,
    text_color: :white

  style :action_arrow,
    width: 9,
    height: 14,
    right: 150,
    top: 17,
    image: "images/sidebar/arrow.png"
end
