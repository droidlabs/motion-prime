module MotionPrime
  module FrameCalculatorMixin
    def calculate_frame_for(parent_bounds, options)
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

      return parent_bounds if width.nil? && height.nil? && right.nil? && bottom.nil?
      frame = CGRectMake(0,0,0,0)

      max_width = parent_bounds.size.width
      max_height = parent_bounds.size.height
      width = 0.0 if width.nil?
      height = 0.0 if height.nil?

      if left && left > 0 && left <= 1 && value_type != 'absolute' && left.is_a?(Float)
        left = max_width * left
      end

      if right && right > 0 && right <= 1 && value_type != 'absolute' && right.is_a?(Float)
        right = max_width * right
      end

      # calculate left and right if width is relative, e.g 0.7
      if width && width > 0 && width <= 1 && value_type != 'absolute' && width.is_a?(Float)
        if right.nil?
          left ||= 0
          right = max_width - max_width * width - left
        else
          left = max_width - max_width * width - right
        end
      end

      # calculate top and bottom if height is relative, e.g 0.7
      if height && height > 0 && height <= 1 && value_type != 'absolute' && width.is_a?(Float)
        if bottom.nil?
          top ||= 0
          bottom = max_height - max_height * height
        else
          top = max_height - max_height * height
        end
      end

      if !left.nil? && !right.nil?
        frame.origin.x = left
        width = max_width - left - right if options[:height_to_fit].nil?
      elsif !right.nil?
        frame.origin.x = max_width - width - right
      elsif !left.nil?
        frame.origin.x = left
      else
        frame.origin.x = max_width / 2 - width / 2
      end
      frame.size.width = width

      if !top.nil? && !bottom.nil?
        frame.origin.y = top
        height = max_height - top - bottom if options[:height_to_fit].nil?
      elsif !bottom.nil?
        frame.origin.y = max_height - height - bottom
      elsif !top.nil?
        frame.origin.y = top
      else
        frame.origin.y = max_height / 2 - height / 2
      end
      frame.size.height = height

      frame
    rescue => e
      Prime.logger.error "can't calculate frame in #{self.class.name}. #{e}"
      CGRectMake(0,0,0,0)
    end
  end
end