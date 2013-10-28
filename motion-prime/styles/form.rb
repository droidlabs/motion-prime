motion_require '../views/styles.rb'
MotionPrime::Styles.define :base_form do

  style :field,
    selection_style: UITableViewCellSelectionStyleNone

  style :with_sections,
    left: 0,
    right: 0

  # available options for string label:
  # @background_color: COLOR
  # @text_color: COLOR
  style :field_label,
    background_color: :clear,
    text_color: :gray,
    top: 6,
    height: 20,
    left: 0,
    right: 0,
    font: proc { MotionPrime::Config.font.name.uifont(12) },
    size_to_fit: true

  style :field_error_message,
    top: nil,
    bottom: 0,
    width: 300,
    line_break_mode: :wordwrap,
    number_of_lines: 0,
    text_color: proc { MotionPrime::Config.color.error }

  # available options for input:
  # @layer: @border_width: FLOAT
  # @layer: @border_color: COLOR
  # @background_color: COLOR
  # @background_image: PATH_TO_FILE
  style :field_text_field, :field_text_view,
    layer: {
      border_width: 1,
      border_color: :gray
    },
    font: proc { MotionPrime::Config.font.name.uifont(16) },
    placeholder_font: proc { MotionPrime::Config.font.name.uifont(16) },
    background_color: :white,
    left: 0,
    right: 0,
    top: 30,
    bottom: 0,
    padding_top: 4

  style :select_field_button,
    background_color: :white,
    left: 0,
    right: 0,
    top: 30,
    height: 36,
    title_color: 0x16759a,
    title_shadow_color: :white,
    contentHorizontalAlignment: UIControlContentHorizontalAlignmentLeft,
    layer: {
      border_color: :gray,
      border_width: 1
    },
    title_color: :gray,
    title_label: {
      font: proc { MotionPrime::Config.font.name.uifont(16) }
    }
  style :select_field_arrow,
    image: "images/forms/select_arrow.png",
    top: 42,
    right: 5,
    width: 9,
    height: 14

  style :with_sections_field_switch,
    right: 20

  style :with_sections_field_text_field, :with_sections_field_text_view, :with_sections_field_password_field, :with_sections_field_label, :with_sections_field_button,
    left: 20,
    right: 20

  style :with_sections_select_field_arrow,
    right: 25

  style :with_sections_switch_field_switch,
    right: 25
  style :with_sections_switch_field_label,
    left: 25
  style :with_sections_switch_hint,
    left: 25

  style :field_input_with_errors,
    layer: {
      border_color: proc { MotionPrime::Config.color.error }
    },
    text_color: proc { MotionPrime::Config.color.error }

  style :field_switch,
    top: 10,
    width: 50,
    height: 27,
    right: 0

  style :switch_field_label,
    top: 10,
    font: proc { MotionPrime::Config.font.name.uifont(16) }

  style :switch_field_hint,
    top: 40,
    font: proc { MotionPrime::Config.font.name.uifont(12) }
end