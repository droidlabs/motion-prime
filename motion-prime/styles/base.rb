motion_require '../views/styles.rb'
MotionPrime::Styles.define :base do
  # basic screen styles
  style :screen,
    background_color: :white

  # basic table styles
  # ----------
  style :table,
    top: 0,
    left: 0,
    width: 320,
    bottom: 0

  style :table_cell,
    background_color: :clear

  # basic form styles
  # ----------
  style :form,
    width: 260,
    left: 30,
    top: 0,
    right: 30,
    bottom: 0,
    background_color: :clear,
    separator_color: :clear,
    scroll_enabled: true

  # available options for submit button:
  # @button_type: :rounded, :custom
  # @background_color: COLOR
  # @background_image: PATH_TO_FILE
  style :submit_button, :form_submit_field_button,
    background_color: :gray,
    title_color: :white,
    left: 0,
    right: 0,
    top: 10,
    height: 44

  style :segmented_control,
    height: 40, width: 320, top: 0

  style :google_map,
    top: 0, left: 0, right: 0, bottom: 0

  style :date_picker, :form_field_date_picker,
    width: 300,
    height: 150,
    top: 30, left: 0
end
