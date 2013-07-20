motion_require '../draw.rb'
module MotionPrime
  class ImageDrawElement < DrawElement
    attr_accessor :image_data
    def draw_in(rect)
      return if computed_options[:hidden]
      image_rect = CGRectMake(
        computed_left,
        computed_top,
        computed_options[:width],
        computed_options[:height]
      )
      # draw already initialized image
      if image_data
        image_data.drawInRect(image_rect)
      # draw image from resources
      elsif computed_options[:image]
        self.image_data = computed_options[:image].uiimage
        image_data.drawInRect(image_rect)
      # show default image and download image from url
      elsif computed_options[:url]
        if computed_options[:default]
          computed_options[:default].uiimage.drawInRect(image_rect)
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
                self.image_data.drawInRect(image_rect)
              end
            end
          } )
      end
    end
  end
end