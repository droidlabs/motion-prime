motion_require '../draw.rb'
module MotionPrime
  class ImageDrawElement < DrawElement
    include DrawBackgroundMixin
    attr_accessor :image_data

    def draw_options
      image = image_data || computed_options[:image]
      image ||= computed_options[:default] if computed_options[:url]

      # already initialized image or image from resources or default image
      super.merge({
        image: image.try(:uiimage),
        inner_rect: CGRectMake(frame_inner_left, frame_inner_top, frame_width, frame_height)
      })
    end

    def draw_in(rect)
      return if computed_options[:hidden]
      super
      if computed_options[:draw_in_rect]
        draw_in_context(UIGraphicsGetCurrentContext())
      else
        draw_background_in_context(UIGraphicsGetCurrentContext())
        draw_with_layer
      end
      load_image
    end

    def draw_in_context(context)
      return if computed_options[:hidden]

      draw_background_in_context(context)
      options = draw_options
      return unless image = options[:image]

      border_width = options[:border_width]
      inset = border_width > 0 ? (border_width - 1 ).abs*0.5 : 0
      rect = CGRectInset(options[:inner_rect], inset, inset)
      radius = options[:corner_radius].to_f if options[:corner_radius] && options[:masks_to_bounds]
      UIGraphicsPushContext(context)
      if radius
        draw_rect_in_context(context, rect: rect, radius: radius, rounded_corners: options[:rounded_corners])
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
      @layer.try(:removeFromSuperlayer)
      return unless image = options[:image]
      rect = options[:inner_rect]

      radius = options[:corner_radius].to_f if options[:corner_radius] && options[:masks_to_bounds]

      @layer = CALayer.layer
      @layer.contents = image.CGImage
      @layer.frame = rect
      @layer.bounds = rect

      @layer.masksToBounds = options[:masks_to_bounds]
      @layer.cornerRadius = radius if radius
      view.layer.addSublayer(@layer)
    end

    def strong_references
      # .compact() is required here, otherwise screen will not be released
      refs = [section, (section.collection_section if section.respond_to?(:cell_section_name))].compact
      refs += section.strong_references if section
      refs
    end

    def load_image
      return if @loading || image_data || !computed_options[:url]
      @loading = true

      ref_key = allocate_strong_references
      BW::Reactor.schedule do
        manager = SDWebImageManager.sharedManager
        manager.downloadWithURL(computed_options[:url],
          options: 0,
          progress: lambda{ |r_size, e_size|  },
          completed: lambda{ |image, error, type, finished|
            if !image || allocated_references_released?
              @loading = false
              release_strong_references(ref_key)
              return
            end

            if computed_options[:post_process].present?
              image = computed_options[:post_process][:method].to_proc.call(computed_options[:post_process][:target], image)
            end
            self.image_data = image
            section.cached_draw_image = nil
            if section.respond_to?(:cell_section_name)
              section.pending_display!
            else
              self.view.performSelectorOnMainThread :setNeedsDisplay, withObject: nil, waitUntilDone: true
            end
            @loading = false
            release_strong_references(ref_key)
          }
        )
      end
    end

    def update_with_options(new_options = {})
      self.image_data = nil if new_options.slice(:url, :image).any? || new_options.blank?
      @layer.try(:removeFromSuperlayer)
      super
    end
  end
end