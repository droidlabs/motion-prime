motion_require '../draw.rb'
module MotionPrime
  class ImageDrawElement < DrawElement
    include DrawBackgroundMixin
    attr_accessor :image_data

    def draw_options
      image = image_data || computed_options[:image]
      image ||= computed_options[:default] if computed_options[:url]

      # already initialized image or image from resources or default image
      super.merge({image: image.try(:uiimage)})
    end

    def draw_in(rect)
      return if computed_options[:hidden]

      draw_background_in_context(UIGraphicsGetCurrentContext())
      computed_options[:draw_in_rect] ? draw_in_context(UIGraphicsGetCurrentContext()) : draw_with_layer
      load_image
    end

    def draw_in_context(context)
      return if computed_options[:hidden]

      draw_background_in_context(context)
      options = draw_options
      return unless image = options[:image]

      border_width = options[:border_width]
      inset = border_width > 0 ? (border_width - 1 ).abs*0.5 : 0
      rect = CGRectInset(options[:rect], inset, inset)
      radius = options[:corner_radius].to_f if options[:corner_radius] && options[:masks_to_bounds]

      UIGraphicsPushContext(context)
      if radius
        CGContextBeginPath(context)
        CGContextAddArc(context, rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2, radius, 0, 2*Math::PI, 0) # FIXME
        CGContextClosePath(context)
        CGContextSaveGState(context)
        CGContextClip(context)
        image.drawInRect(rect)
        CGContextRestoreGState(context)
      else
        image.drawInRect(rect)
      end
      UIGraphicsPopContext()
    end

    def draw_with_layer
      options = draw_options
      return unless image = options[:image]
      rect = options[:rect]
      radius = options[:corner_radius].to_f if options[:corner_radius] && options[:masks_to_bounds]

      layer = CALayer.layer
      layer.contents = image.CGImage
      layer.frame = rect
      layer.bounds = rect

      layer.masksToBounds = options[:masks_to_bounds]
      layer.cornerRadius = radius if radius

      view.layer.addSublayer(layer)
    end

    def load_image
      return if image_data || !computed_options[:url]
      # TODO: why so many references?
      @strong_refs = section.strong_references + [screen.main_controller.strong_ref]
      BW::Reactor.schedule do
        manager = SDWebImageManager.sharedManager
        manager.downloadWithURL(computed_options[:url],
          options: 0,
          progress: lambda{ |r_size, e_size|  },
          completed: lambda{ |image, error, type, finished|
            if !image || screen.main_controller.retainCount == 1 || section.retainCount == 1
              @strong_refs = nil
              return
            end

            self.image_data = image

            section.cached_draw_image = nil
            if section.respond_to?(:cell_name)
              section.pending_display!
            else
              self.view.performSelectorOnMainThread :setNeedsDisplay, withObject: nil, waitUntilDone: false
            end
            @strong_refs = nil
          }
        )
      end
    end
  end
end