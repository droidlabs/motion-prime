Prime::Styles.define :sidebar do
  # navigation layout
  # ----------
  style :screen,
    background_color: Prime::Config.color.base,
    opaque: true

  style :table,
    top: 0,
    left: 0,
    width: 320,
    bottom: 0,
    background_color: Prime::Config.color.base,
    separator_color: Prime::Config.color.dark,
    opaque: true

  style :table_cell,
    selection_style: UITableViewCellSelectionStyleNone,
    opaque: true

  style :action_title,
    background_color: Prime::Config.color.base,
    text_color: :white,
    top: 10,
    width: 320,
    opaque: true,
    font: proc { :system.uifont(20) },
    size_to_fit: true,
    left: 20,
    text_color: :white

  style :action_arrow,
    width: 9,
    height: 14,
    right: 50,
    top: 14,
    image: "images/sidebar/arrow.png"
end
