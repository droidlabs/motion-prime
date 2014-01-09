motion_require '../views/_frame_calculator_mixin'
module MotionPrime
  class DrawElement < BaseElement
    # MotionPrime::DrawElement is container for drawRect method options.
    # Elements are located inside Sections

    include FrameCalculatorMixin
    include ElementContentPaddingMixin

    def draw_options
      background_color = options[:background_color].try(:uicolor)
      layer = options[:layer]
      {
        rect: CGRectMake(computed_left, computed_top, computed_outer_width, computed_outer_height),
        background_color: background_color,
        masks_to_bounds: layer.try(:[], :masks_to_bounds) || options[:clips_to_bounds],
        corner_radius: layer.try(:[], :corner_radius).to_f,
        border_width: layer.try(:[], :border_width).to_f,
        border_color: layer.try(:[], :border_color).try(:uicolor) || background_color
      }
    end

    def render!; end

    def view
      @view ||= section.container_view
    end

    def computed_frame
      @computed_frame ||= calculate_frome_for(view.try(:bounds) || section.container_bounds, options)
    end

    def default_padding_for(side)
      0
    end

    def computed_max_width
      view.bounds.size.width
    end

    def computed_max_height
      view.bounds.size.height
    end

    def computed_outer_width; computed_frame.size.width end
    def computed_width; computed_outer_width - content_padding_width end

    def computed_outer_height; computed_frame.size.height end
    def computed_height; computed_outer_height - content_padding_height end

    def computed_top; computed_frame.origin.y end
    def computed_inner_top; computed_top + content_padding_top end

    def computed_left; computed_frame.origin.x end
    def computed_inner_left; computed_left + content_padding_left end

    def computed_bottom; computed_top + computed_outer_height end
    def computed_inner_bottom; computed_bottom - content_padding_bottom end

    def computed_right; computed_left + computed_width end
    def computed_inner_right; computed_right - content_padding_right end

    def bind_gesture(action, receiver = nil)
      section.bind_gesture_on_container_for(self, action, receiver)
    end

    def hide
      options[:hidden] = true
      view.setNeedsDisplay
    end

    def show
      options[:hidden] = false
      view.setNeedsDisplay
    end

    def update_with_options(new_options = {})
      options.merge!(new_options)
      view.setNeedsDisplay
    end

    private
      def reset_computed_values
        @content_height = nil
        @content_width = nil
        @computed_frame = nil
      end

    class << self
      def factory(type, options = {})
        return unless %w[view label image].include?(type.to_s.downcase)
        class_factory("#{type}_draw_element", true).new(options)
      end
    end
  end
end