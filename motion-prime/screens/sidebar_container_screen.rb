module MotionPrime
  class SidebarContainerScreen < PKRevealController

    include ::MotionPrime::ScreenBaseMixin

    def self.new(menu, content, options={})
      screen = self.revealControllerWithFrontViewController(nil, leftViewController: nil, options: nil)
      screen.on_create(options) if screen.respond_to?(:on_create)
      screen.menu_controller = menu unless menu.nil?
      screen.content_controller = content unless content.nil?
      screen
    end

    def show_sidebar
      show_controller menu_controller
    end

    def hide_sidebar
      show_controller content_controller
    end

    def menu_controller=(c)
      setLeftViewController prepare_controller(c),
        focusAfterChange: true, completion: default_completion_block
    end

    def content_controller=(c)
      setFrontViewController prepare_controller(c),
        focusAfterChange: true, completion: default_completion_block
    end

    def menu_controller
      self.leftViewController
    end

    def content_controller
      self.frontViewController
    end

    private

      def show_controller(controller)
        showViewController controller, animated: true, completion: default_completion_block
      end

      def prepare_controller(controller)
        controller.on_screen_load if controller.respond_to?(:on_screen_load)
        controller = setup_screen_for_open(controller, {})
        ensure_wrapper_controller_in_place(controller, {})
        controller = controller.main_controller if controller.respond_to?(:main_controller)
        controller
      end

      def default_completion_block
        -> (completed) { true }
      end
  end
end