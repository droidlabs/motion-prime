module MotionPrime
  module HasStyles
    def prepare_gradient(options)
      colors = options[:colors].map(&:uicolor).map(&:cgcolor)
      locations = options[:locations] if options[:locations]
      type = options[:type].to_s

      if self.is_a?(ViewStyler)
        gradient = CAGradientLayer.layer
        if type == 'horizontal'
          gradient.startPoint = CGPointMake(0, 0.5)
          gradient.endPoint = CGPointMake(1.0, 0.5)
        end
        gradient.frame = if options[:frame_width]
          CGRectMake(options[:frame_x].to_f, options[:frame_y].to_f, options[:frame_width].to_f, options[:frame_height].to_f)
        else
          options[:parent_frame] || CGRectZero
        end

        gradient.colors = colors
        gradient.locations = locations
      else
        color_space = CGColorSpaceCreateDeviceRGB()
        locations_pointer = Pointer.new(:float, 2)
        locations.each_with_index { |loc, id| locations_pointer[id] = loc }
        gradient = CGGradientCreateWithColors(color_space, colors, locations_pointer)
        # CGColorSpaceRelease(color_space)
      end
      gradient
    end
  end
end