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
    bottom: 0,
    separator_inset: 0

  style :table_cell,
    background_color: :clear

  # basic form styles
  # ----------
  style :form,
    width: 320,
    left: 0,
    top: 0,
    right: 0,
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
    left: 20,
    right: 20,
    top: 10,
    height: 44

  style :segmented_control,
    height: 40, width: 320, top: 0

  style :google_map,
    top: 0, left: 0, right: 0, bottom: 0

  style :spinner,
    annular: true,
    center: proc { screen.view.center }, width: 37, height: 37,
    progress_tint_color: proc { :app_base.uicolor },
    background_tint_color: proc { :black.uicolor(0.05) },
    progress: 0.25

  style :spinner_message, mixins: [:multiline],
    top: proc { screen.view.center.y + 38 }, left: 50, width: 220, text_alignment: :center,
    font: proc { :app_base.uifont(18) },
    line_spacing: 6
end
