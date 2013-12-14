motion_require '../draw.rb'
module MotionPrime
  class ImageDrawElement < DrawElement
    include DrawBackgroundMixin
    attr_accessor :image_data

    def draw_in(rect)
      return if computed_options[:hidden]
      options = computed_options
      image_rect = CGRectMake(
        computed_left,
        computed_top,
        computed_width,
        computed_height
      )

      image_rect = CGRectInset(image_rect, -0.5, -0.5)
      border_width = options[:layer].try(:[], :border_width).to_f

      draw_background_in(image_rect, options)

      # draw already initialized image
      if image_data
        draw_with_layer(image_data, image_rect)
      # draw image from resources
      elsif computed_options[:image]
        self.image_data = computed_options[:image].uiimage
        draw_with_layer(image_data, image_rect)
      # show default image and download image from url
      elsif computed_options[:url]
        if computed_options[:default]
          self.image_data = computed_options[:default].uiimage
          draw_with_layer(image_data, image_rect)
        end
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
                draw_with_layer(image_data, image_rect)
              end
            end
          } )
      end
    end

    def draw_with_layer(image, rect)
      layer = CALayer.layer
      layer.contents = image.CGImage
      layer.frame = rect
      layer.bounds = rect
      if computed_options[:layer]
        layer.masksToBounds = computed_options[:layer][:masks_to_bounds] || computed_options[:clips_to_bounds]
        if radius = computed_options[:layer][:corner_radius]
          k = image.size.width / rect.size.width
          radius = radius * k
          layer.cornerRadius = radius
        end
      end
      view.layer.addSublayer layer
    end
  end
end