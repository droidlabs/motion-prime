module MotionPrime
  class ImageElement < BaseElement
    after_render :fetch_image

    def view_class
      "UIImageView"
    end

    def fetch_image
      return unless computed_options[:url]
      raise "You must set default image for `#{name}`" unless computed_options[:default]

      view.setImage(computed_options[:default].uiimage)
      refs = strong_references
      BW::Reactor.schedule do
        manager = SDWebImageManager.sharedManager
        manager.downloadWithURL(computed_options[:url],
          options: 0,
          progress: lambda{ |r_size, e_size|  },
          completed: lambda{ |image, error, type, finished|
            return if !image || !refs.all?(&:weakref_alive?)

            if computed_options[:post_process].present?
              image = computed_options[:post_process][:method].to_proc.call(computed_options[:post_process][:target], image)
            end

            self.performSelectorOnMainThread :set_image, withObject: image, waitUntilDone: true
          }
        )
      end
    end

    def set_image(*args)
      self.view.setImage(args)
    end

    def strong_references
      # .compact() is required here, otherwise screen will not be released
      refs = [section, (section.collection_section if section.respond_to?(:cell_section_name))].compact
      refs += section.strong_references if section
      refs
    end
  end
end