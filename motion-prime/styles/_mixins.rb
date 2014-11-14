motion_require '../views/styles'
MotionPrime::Styles.define :_mixin do
  style :label_reset,
    top: nil, left: nil, height: nil, right: nil, bottom: nil, top: nil,
    padding: nil, padding_top: nil, padding_left: nil, padding_right: nil, padding_bottom: nil,
    size_to_fit: false

  style :multiline,
    size_to_fit: true,
    number_of_lines: 0,
    line_break_mode: :word_wrap,
    line_spacing: 2,
    height: nil
end
