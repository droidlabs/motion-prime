motion_require '../draw.rb'
module MotionPrime
  class ImageDrawElement < DrawElement
    include DrawBackgroundMixin
    attr_accessor :image_data

    def draw_options
      image = image_data || computed_options[:image]
      image ||= computed_options[:default] if computed_options[:url]

      super.merge({image: image.try(:uiimage)})
    end

    def draw_in(rect)
      return if computed_options[:hidden]

      # draw already initialized image or image from resources or default image
      draw_in_context(UIGraphicsGetCurrentContext())
      load_image
    end

    def draw_in_context(context)
      return if computed_options[:hidden]

      draw_background_in_context(context)

      if image = draw_options[:image]
        UIGraphicsPushContext(context)
        draw_with_layer(image)
        UIGraphicsPopContext()
      end
    end

    def draw_with_layer(image)
      options = draw_options
      rect = options[:rect]

      if options[:corner_radius] && options[:masks_to_bounds]
        layer = CALayer.layer
        layer.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        layer.contents = image.CGImage

        layer.masksToBounds = options[:masks_to_bounds]
        radius = options[:corner_radius]
        k = image.size.width / rect.size.width
        radius = radius * k
        layer.cornerRadius = radius

        UIGraphicsBeginImageContext(image.size)
        layer.renderInContext(UIGraphicsGetCurrentContext())
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        # CGContextBeginPath(context)
        # CGContextAddArc(context, 225, 225, 100, 0, 2*Math::PI, 0)
        # CGContextClosePath(context)
        # CGContextSaveGState()
        # CGContextClip(context)
        # draw
        # CGContextRestoreGState()
        image.drawInRect(rect)
      else
        image.drawInRect(rect)
      end
    end

    def load_image
      return unless computed_options[:url]
      manager = SDWebImageManager.sharedManager
      manager.downloadWithURL(computed_options[:url],
        options: 0,
        progress: lambda{ |r_size, e_size|  },
        completed: lambda{ |image, error, type, finished|
          if image
            self.image_data = image
            if type == SDImageCacheTypeNone || type == SDImageCacheTypeDisk
              # if it's first call, we should redraw view, because it's async
              section.container_view.setNeedsDisplay
            else
              # if it's second call, we should just draw image
              draw_with_layer(image_data)
            end
          end
        }
      )
    end
  end
end