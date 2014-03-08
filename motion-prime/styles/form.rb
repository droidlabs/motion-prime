motion_require '../views/styles.rb'
MotionPrime::Styles.define :base_form do
  style :header, container: {height: 25}
  style :header_label, mixins: [:multiline],
    left: 0,
    bottom: 5,
    top: nil,
    width: 320,
    size_to_fit: true

  style :header_hint,
    left: 0,
    bottom: 5,
    top: nil,
    width: 320

  style :field, :cell,
    selection_style: :none,
    background_color: :clear

  style :with_sections,
    left: 0,
    right: 0

  style :field_label,
    background_color: :clear,
    text_color: :gray,
    top: 15,
    height: 16,
    left: 0,
    right: 20,
    font: proc { :app_base.uifont(12) },
    size_to_fit: true

  style :field_error_message, mixins: [:multiline],
    top: nil,
    bottom: 0,
    width: 280,
    left: 0,
    text_color: :app_error,
    font: proc { :app_base.uifont(12) }

  style :string_field_input, :password_field_input, :text_field_input,
    layer: {
      border_width: 1,
      border_color: :gray
    },
    font: proc { :app_base.uifont(16) },
    placeholder_font: proc { :app_base.uifont(16) },
    background_color: :white,
    left: 0,
    right: 20,
    top: 30,
    height: 30

  style :date_field_input,
    width: 300,
    height: 150,
    top: 30, left: 0

  style :select_field_button,
    background_color: :white,
    left: 0,
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
      font: proc {:app_base.uifont(16) }
    }

  style :select_field_arrow,
    image: "images/forms/select_arrow.png",
    top: 40,
    right: 25,
    width: 9,
    height: 14



  style :with_sections_field_switch,
    right: 20

  style :with_sections_field_text_field,
    :with_sections_field_text_view,
    :with_sections_field_password_field,
    :with_sections_field_label,
    :with_sections_field_button,
    left: 20,
    right: 20

  style :with_sections_select_field_image,
    right: 25

  style :with_sections_switch_field_input,
    right: 25
  style :with_sections_switch_field_label,
    left: 25
  style :with_sections_switch_hint,
    left: 25

  style :field_input_with_errors,
    layer: {
      border_color: :app_error
    },
    text_color: :app_error

  style :switch_field_input,
    top: 10,
    right: 0,
    width: 51

  style :switch_field_label,
    top: 10,
    font: proc { :app_base.uifont(16) }

  style :switch_field_hint,
    top: 40,
    font: proc { :app_base.uifont(12) }
end
