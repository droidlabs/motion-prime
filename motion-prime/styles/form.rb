motion_require '../views/styles.rb'
MotionPrime::Styles.define :base_form do
  style :header, container: {height: 25}
  style :header_label, mixins: [:multiline],
    left: 0,
    bottom: 5,
    top: nil,
    right: 0,
    size_to_fit: true

  style :header_hint,
    left: 0,
    bottom: 5,
    top: nil,
    right: 0

  style :field, :cell,
    selection_style: :none,
    background_color: :clear

  style :field_label,
    background_color: :clear,
    text_color: :gray,
    top: 15,
    height: 16,
    left: 20,
    right: 20,
    font_name: :app_base,
    font_size: 12,
    size_to_fit: true

  style :field_error_message, mixins: [:multiline],
    top: nil,
    bottom: 0,
    left: 20,
    right: 20,
    text_color: :app_error,
    font_name: :app_base,
    font_size: 12

  style :string_field_input, :password_field_input, :text_field_input,
    layer: {
      border_width: 1,
      border_color: :gray
    },
    font_name: :app_base,
    font_size: 16,
    placeholder_font_name: :app_base,
    placeholder_font_size: 16,
    background_color: :white,
    left: 20,
    right: 20,
    top: 30,
    height: 30

  style :date_field_input,
    height: 150,
    top: 30,
    left: 20,
    right: 20

  style :select_field_button,
    background_color: :white,
    left: 20,
    right: 20,
    top: 30,
    height: 35,
    title_shadow_color: :white,
    content_horizontal_alignment: :left,
    layer: {
      border_color: :gray,
      border_width: 1
    },
    title_color: :gray,
    title_label: {
      font_name: :app_base,
      font_size: 16
    }

  style :select_field_arrow,
    image: "images/forms/select_arrow.png",
    top: 40,
    right: 25,
    width: 9,
    height: 14

  style :switch_field_input,
    top: 10,
    right: 20,
    width: 51

  style :switch_field_label,
    top: 10,
    font_name: :app_base,
    font_size: 16

  style :switch_field_hint,
    top: 40,
    font_name: :app_base,
    font_size: 12

  style :field_input_with_errors,
    layer: {
      border_color: :app_error
    },
    text_color: :app_error
end
