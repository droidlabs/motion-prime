module MotionPrime
  class ImageElement < BaseElement
    after_render :fetch_image
    def view_class
      "UIImageView"
    end

    def fetch_image
      return unless options[:url]
      raise "You must set default image for `#{name}`" unless options[:default]
      view.setImageWithURL NSURL.URLWithString(options[:url]),
                        placeholderImage: options[:default].uiimage
    end
  end
end