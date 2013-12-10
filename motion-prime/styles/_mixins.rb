motion_require '../views/styles.rb'
MotionPrime::Styles.define :_mixin do
  style :multiline,
    size_to_fit: true,
    number_of_lines: 0,
    line_break_mode: :wordwrap,
    line_spacing: 2
end