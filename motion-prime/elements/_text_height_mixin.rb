module MotionPrime
  module ElementTextHeightMixin
    def content_height
      width = computed_options[:width]
      font = computed_options[:font] || :system.uifont
      raise "Please set element width for height calculation" unless width
      computed_options[:text].sizeWithFont(font,
            constrainedToSize: [width, Float::MAX],
            lineBreakMode: UILineBreakModeWordWrap).height
    end

    def content_outer_height
      content_height + computed_inner_top + computed_inner_bottom
    end
  end
end