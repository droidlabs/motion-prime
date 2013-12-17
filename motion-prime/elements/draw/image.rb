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
      border_width = options[:border_width]
      inset = border_width > 0 ? (border_width - 1 ).abs*0.5 : 0
      rect = CGRectInset(options[:rect], inset, inset)
      radius = options[:corner_radius].to_f if options[:corner_radius] && options[:masks_to_bounds]

      if radius
        context = UIGraphicsGetCurrentContext()
        CGContextBeginPath(context)
        CGContextAddArc(context, rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2, radius, 0, 2*Math::PI, 0)
        CGContextClosePath(context)
        CGContextSaveGState(context)
        CGContextClip(context)
        image.drawInRect(rect)
        CGContextRestoreGState(context)
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