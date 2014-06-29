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
      temp_width = width || 0.0
      temp_height = height || 0.0

      if left && left > 0 && left <= 1 && value_type != 'absolute' && left.is_a?(Float)
        left = (max_width * left).round(2)
      end

      if right && right > 0 && right <= 1 && value_type != 'absolute' && right.is_a?(Float)
        right = (max_width * right).round(2)
      end

      if top && top > 0 && top <= 1 && value_type != 'absolute' && top.is_a?(Float)
        top = (max_height * top).round(2)
      end

      if bottom && bottom > 0 && bottom <= 1 && value_type != 'absolute' && bottom.is_a?(Float)
        bottom = (max_height * bottom).round(2)
      end

      # calculate left and right if width is relative, e.g 0.7
      if width && width > 0 && width <= 1 && value_type != 'absolute' && width.is_a?(Float)
        if right.nil?
          left ||= 0
          right = (max_width - max_width * width - left).round(2)
        else
          left = (max_width - max_width * width - right).round(2)
        end
        width = (max_width * width).round(2)
      end

      # calculate top and bottom if height is relative, e.g 0.7
      if height && height > 0 && height <= 1 && value_type != 'absolute' && height.is_a?(Float)
        if bottom.nil?
          top ||= 0
          bottom = (max_height - max_height * height - top).round(2)
        else
          top = (max_height - max_height * height - bottom).round(2)
        end
        height = (max_height * height).round(2)
      end

      if !left.nil? && !right.nil?
        frame.origin.x = left
        if options[:height_to_fit].nil? && width.nil?
          width = max_width - left - right
        end
      elsif !right.nil?
        frame.origin.x = max_width - temp_width - right
      elsif !left.nil?
        frame.origin.x = left
      else
        frame.origin.x = max_width / 2 - temp_width / 2
      end
      frame.size.width = width || 0.0

      if !top.nil? && !bottom.nil?
        frame.origin.y = top
        if options[:height_to_fit].nil? && height.nil?
          height = max_height - top - bottom
        end
      elsif !bottom.nil?
        frame.origin.y = max_height - temp_height - bottom
      elsif !top.nil?
        frame.origin.y = top
      else
        frame.origin.y = max_height / 2 - temp_height / 2
      end
      frame.size.height = height || 0.0

      frame
    rescue => e
      Prime.logger.error "can't calculate frame in #{self.class.name}. #{e}"
      CGRectMake(0,0,0,0)
    end
  end
end