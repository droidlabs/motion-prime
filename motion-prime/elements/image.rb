module MotionPrime
  class ImageElement < BaseElement
    after_render :fetch_image
    def view_class
      "UIImageView"
    end

    def fetch_image
      return unless computed_options[:url]
      raise "You must set default image for `#{name}`" unless computed_options[:default]
      view.setImageWithURL NSURL.URLWithString(computed_options[:url]),
                        placeholderImage: computed_options[:default].uiimage
    end
  end
end