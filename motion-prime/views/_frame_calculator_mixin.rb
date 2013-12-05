module MotionPrime
  module FrameCalculatorMixin
    def calculate_frome_for(bounds, options)
      width   = options[:width]
      height  = options[:height]
      top     = options[:top]
      right   = options[:right]
      bottom  = options[:bottom]
      left    = options[:left]
      value_type = options[:value_type].to_s # absolute/relative

      if options[:height_to_fit].present? && height.nil? && (top.nil? || bottom.nil?)
        height = options[:height_to_fit]
      end

      return bounds if width.nil? && height.nil? && right.nil? && bottom.nil?
      frame = CGRectMake(0,0,0,0)

      max_width = bounds.size.width
      max_height = bounds.size.height
      width = 0.0 if width.nil?
      height = 0.0 if height.nil?

      # calculate left and right if width is relative, e.g 0.7
      if width && width > 0 && width <= 1 && value_type != 'absolute'
        if right.nil?
          left ||= 0
          right = max_width - max_width * width
        else
          left = max_width - max_width * width
        end
      end

      # calculate top and bottom if height is relative, e.g 0.7
      if height && height > 0 && height <= 1 && value_type != 'absolute'
        if bottom.nil?
          top ||= 0
          bottom = max_height - max_height * height
        else
          top = max_height - max_height * height
        end
      end

      if !left.nil? && !right.nil?
        frame.origin.x = left
        frame.size.width = max_width - left - right
      elsif !right.nil?
        frame.origin.x = max_width - width - right
        frame.size.width = width
      elsif !left.nil?
        frame.origin.x = left
        frame.size.width = width
      else
        frame.origin.x = max_width / 2 - width / 2
        frame.size.width = width
      end

      if !top.nil? && !bottom.nil?
        frame.origin.y = top
        frame.size.height = max_height - top - bottom
      elsif !bottom.nil?
        frame.origin.y = max_height - height - bottom
        frame.size.height = height
      elsif !top.nil?
        frame.origin.y = top
        frame.size.height = height
      else
        frame.origin.y = max_height / 2 - height / 2
        frame.size.height = height
      end

      frame
    end
  end
end