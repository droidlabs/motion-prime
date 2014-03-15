motion_require '../views/_frame_calculator_mixin'
module MotionPrime
  class DrawElement < BaseElement
    # MotionPrime::DrawElement is container for drawRect method options.
    # Elements are located inside Sections

    include FrameCalculatorMixin
    include ElementContentPaddingMixin

    def draw_options
      options = computed_options
      background_color = options[:background_color].try(:uicolor)
      {
        rect: CGRectMake(frame_left, frame_top, frame_outer_width, frame_outer_height),
        background_color: background_color,
        masks_to_bounds: options[:layer].try(:[], :masks_to_bounds) || options[:clips_to_bounds],
        corner_radius: options[:layer].try(:[], :corner_radius).to_f,
        border_width: options[:layer].try(:[], :border_width).to_f,
        border_color: options[:layer].try(:[], :border_color).try(:uicolor) || background_color
      }
    end

    def render!; end

    def view
      @view ||= section.container_view
    end

    def computed_frame
      @computed_frame ||= calculate_frame_for(view.try(:bounds) || section.container_bounds, computed_options)
    end

    def default_padding_for(side)
      0
    end

    def bind_gesture(action, receiver = nil, target = nil)
      target ||= section
      target.bind_gesture_on_container_for(self, action, receiver)
    end

    def hide
      return if computed_options[:hidden]
      computed_options[:hidden] = true
      section.cached_draw_image = nil
      view.setNeedsDisplay
    end

    def show
      return if !computed_options[:hidden]
      computed_options[:hidden] = false
      section.cached_draw_image = nil
      view.setNeedsDisplay
    end

    def reload!
      reset_computed_values
      compute_options!
      section.cached_draw_image = nil
    end

    def update_with_options(new_options = {})
      options.merge!(new_options)
      reload!
      view.setNeedsDisplay
    end

    private
      def frame_outer_width; computed_frame.size.width end
      def frame_width; frame_outer_width - content_padding_width end

      def frame_outer_height; computed_frame.size.height end
      def frame_height; frame_outer_height - content_padding_height end

      def frame_top; computed_frame.origin.y end
      def frame_inner_top; frame_top + content_padding_top end

      def frame_left; computed_frame.origin.x end
      def frame_inner_left; frame_left + content_padding_left end

      def frame_bottom; frame_top + frame_outer_height end
      def frame_inner_bottom; frame_bottom - content_padding_bottom end

      def frame_right; frame_left + frame_outer_width end
      def frame_inner_right; frame_right - content_padding_right end

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