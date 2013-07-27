module MotionPrime
  module ElementTextHeightMixin
    def height
      width = computed_options[:width]
      font = computed_options[:font] || :system.uifont
      raise "Please set element width for height calculation" unless width
      computed_options[:text].sizeWithFont(font,
            constrainedToSize: [width, Float::MAX],
            lineBreakMode: UILineBreakModeWordWrap).height
    end

    def outer_height
      height + computed_options[:top].to_i +
      computed_options[:bottom].to_i
    end
  end
end