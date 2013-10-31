motion_require "./_aliases_mixin"
motion_require "./_orientations_mixin"
motion_require "./_navigation_mixin"
motion_require "./_navigation_bar_mixin"
module MotionPrime
  module ScreenBaseMixin
    extend ::MotionSupport::Concern

    include ::MotionSupport::Callbacks
    include MotionPrime::ScreenAliasesMixin
    include MotionPrime::ScreenOrientationsMixin
    include MotionPrime::ScreenNavigationMixin
    include MotionPrime::ScreenNavigationBarMixin

    attr_accessor :parent_screen, :modal, :params, :main_section
    class_attribute :current_screen

    included do
      define_callbacks :load
    end

    def on_load; end

    def on_screen_load
      run_callbacks :load do
        on_load
      end
    end

    def on_create(args = {})
      unless self.is_a?(UIViewController)
        raise StandardError.new("ERROR: Screens must extend UIViewController.")
      end

      self.params = args[:params] || {}
      args.each do |k, v|
        self.send("#{k}=", v) if self.respond_to?("#{k}=")
      end

      @wrap_in_navigation = args[:navigation]

      self.on_init if respond_to?(:on_init)
      self
    end

    def wrap_in_navigation?
      @wrap_in_navigation
    end

    def modal?
      !!self.modal
    end

    def has_navigation?
      !navigation_controller.nil?
    end

    def navigation_controller
      @navigation_controller ||= self.navigationController
    end

    def navigation_controller=(val)
      @navigation_controller = val
    end

    def title
      title = self.class.title
      title = self.instance_eval(&title) if title.is_a?(Proc)
      title
    end

    def title=(new_title)
      self.class.title(new_title)
      super
    end

    def main_controller
      has_navigation? ? navigation_controller : self
    end

    # ACTIVITY INDICATOR
    # ---------------------

    def show_activity_indicator
      if @activity_indicator_view.nil?
        @activity_indicator_view = UIActivityIndicatorView.gray
        @activity_indicator_view.center = CGPointMake(view.center.x, view.center.y - 50)
        view.addSubview @activity_indicator_view
      end
      @activity_indicator_view.startAnimating
    end

    def hide_activity_indicator
      return unless @activity_indicator_view
      @activity_indicator_view.stopAnimating
    end

    def show_notice(message, time = 1.0)
      MBHUDView.hudWithBody message,
        type: MBAlertViewHUDTypeCheckmark, hidesAfter: time, show: true
    end

    def refresh
      main_section.reload_data
    end

    # Class methods
    module ClassMethods
      def title(t = nil)
        t ? @title = t : @title ||= self.to_s
      end
      def before_load(method_name)
        set_callback :load, :before, method_name
      end
      def after_load(method_name)
        set_callback :load, :after, method_name
      end
    end
  end
end