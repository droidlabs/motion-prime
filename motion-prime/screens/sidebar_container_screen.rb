module MotionPrime
  class SidebarContainerScreen < RESideMenu
    include ::MotionPrime::ScreenBaseMixin

    def self.new(menu, content, options={})
      screen = self.alloc.initWithContentViewController(nil, menuViewController: nil)
      screen.backgroundImage = "images/sidebar/background.png".uiimage

      full_width = UIScreen.mainScreen.bounds.size.width
      screen.contentViewInPortraitOffsetCenterX = full_width*(1 + screen.contentViewScaleValue/2) - 45
      screen.contentViewInPortraitOffsetCenterY = UIScreen.mainScreen.bounds.size.height/2 + 30

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
      if content_controller.nil?
        self.setContentViewController controller
      else
        content_controller.viewControllers = [controller]
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