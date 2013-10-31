module MotionPrime
  class SidebarContainerScreen < REFrostedViewController
    include ::MotionPrime::ScreenBaseMixin

    def self.new(menu, content, options={})
      screen = self.alloc.initWithContentViewController(nil, menuViewController: nil)
      screen.direction = REFrostedViewControllerDirectionLeft
      screen.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight
      screen.blurTintColor = :black.uicolor

      screen.on_create(options) if screen.respond_to?(:on_create)
      screen.menu_controller = menu unless menu.nil?
      screen.content_controller = content unless content.nil?

      screen
    end

    def show_sidebar
      self.presentMenuViewController
    end

    def hide_sidebar
      self.hideMenuViewController
    end

    def menu_controller=(c)
      self.setMenuViewController prepare_controller(c)
    end

    def content_controller=(c)
      controller = prepare_controller(c)
      puts controller.to_s
      if content_controller.nil?
        self.setContentViewController controller
      else#if controller.is_a?(MotionPrime::NavigationController)
        content_controller.viewControllers = [controller]
      # else
      #   self.setContentViewController controller

      #   old_content = content_controller
      #   re_displayController(controller, frame: self.view.frame)
      #   old_content.view.removeFromSuperview
      #   old_content.removeFromParentViewController
      end
      hide_sidebar
    end

    def menu_controller
      self.menuViewController
    end

    def content_controller
      self.contentViewController
    end

    private

      def prepare_controller(controller)
        controller = setup_screen_for_open(controller, {})
        controller.send(:on_screen_load) if controller.respond_to?(:on_screen_load)

        if content_controller.nil?
          controller.ensure_wrapper_controller_in_place
          controller = controller.main_controller if controller.respond_to?(:main_controller)
        else
          controller.navigation_controller = content_controller
        end
        controller
      end
  end
end