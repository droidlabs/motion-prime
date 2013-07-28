module MotionPrime
  class DrawSection < BaseSection
    # MotionPrime::DrawSection is container for Elements.
    # Unlike BaseSection, DrawSection renders elements using drawRect, instead of creating subviews
    # NOTE: only image and label elements are supported at this moment

    # == Basic Sample
    # class MySection < MotionPrime::DrawSection
    #   element :title, text: "Hello World"
    #   element :avatar, type: :image, image: 'defaults/avatar.jpg'
    # end
    #

    attr_accessor :container_view

    def create_elements
      self.elements = {}
      (self.class.elements_options || {}).each do |key, opts|
        # we should clone options to prevent overriding options
        # in next element with same name in another class
        options = opts.clone
        options[:section] = self
        self.elements[key] = MotionPrime::DrawElement.factory(options.delete(:type), options)
      end
    end

    def render!
      if container_options[:as].to_s == 'cell'
        @container_view = screen.add_view DMCellWithSection, {
          section: self, styles: container_options[:styles],
          reuse_identifier: container_options[:reuse_identifier]
        }
      else
        @container_view = screen.add_view DMViewWithSection, {
          section: self, styles: container_options[:styles],
          width: container_options[:width] || 320,
          height: container_options[:height] || 100,
          top: container_options[:top] || 0,
          left: container_options[:left] || 0
        }
      end
    end

    def hide
      container_view.hidden = true
    end

    def show
      container_view.hidden = false
    end

    # @container_view (DMViewWithSection) will call this method on draw
    def draw_in(rect)
      draw_background(rect)
      draw_elements(rect)
    end

    def draw_elements(rect)
      elements.each do |key, element|
        element.draw_in(rect)
      end
    end

    def draw_background(rect)
      if container_options[:background_color]
        container_options[:background_color].uicolor.setFill
        UIRectFill(rect)
      end
    end
  end
end