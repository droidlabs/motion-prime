module MotionPrime
  module SupportControlContentAlignment
    VERTICAL_ALIGNMENT_CONSTS = {
      UIControlContentVerticalAlignmentCenter => :center,
      UIControlContentVerticalAlignmentTop => :top,
      UIControlContentVerticalAlignmentBottom => :bottom,
      UIControlContentVerticalAlignmentFill => :fill # TODO: handle this value
    }
    def setContentVerticalAlignment(value)
      return unless @_content_vertical_alignment = VERTICAL_ALIGNMENT_CONSTS[value]
      super
    end

    def padding_top
      padding_top = self.paddingTop || self.padding
      if @_content_vertical_alignment == :bottom
        padding_bottom = self.paddingBottom || self.padding
        bounds_height - padding_bottom.to_i - line_height
      elsif @_content_vertical_alignment == :top
        padding_top.to_i
      else # center label
        padding_top_offset = padding_top.to_i - (self.paddingBottom || self.padding).to_i
        (bounds_height - line_height)/2 + padding_top_offset
      end
    end

    def padding_bottom
      (bounds_height - (line_height + padding_top))
    end

    def line_height
      @_line_height || self.font.pointSize
    end

    def bounds_height
      self.bounds.size.height
    end
  end
end