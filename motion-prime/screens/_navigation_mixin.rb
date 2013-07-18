module MotionPrime
  module ScreenNavigationMixin
    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def open_screen(screen, args = {})
      # Apply properties to instance
      screen = setup_screen_for_open(screen, args)
      ensure_wrapper_controller_in_place(screen, args)
      screen.send(:on_screen_load) if screen.respond_to?(:on_screen_load)
      if args[:modal]
        present_modal_view_controller screen, (args[:animated] || true)
      elsif has_navigation?
        push_view_controller screen
      else
        app_delegate.open_screen(screen.main_controller)
      end
    end

    def open_root_screen(screen)
      app_delegate.open_root_screen(screen)
    end

    def show_sidebar
      app_delegate.show_sidebar
    end

    def hide_sidebar
      app_delegate.hide_sidebar
    end

    def close_screen(args = {})
      args ||= {}
      args[:animated] ||= true
      # Pop current view, maybe with arguments, if in navigation controller
      if modal?
        close_modal_screen args
      elsif has_navigation?
        close_navigation args
        send_on_return(args)
      end
    end

    def back
      close_screen
    end

    def send_on_return(args = {})
      if parent_screen && parent_screen.respond_to?(:on_return)
        parent_screen.send(:on_return)
      end
    end

    def push_view_controller(vc)
      navigation_controller.pushViewController(vc, animated: true)
    end

    protected

    def setup_screen_for_open(screen, args = {})
      # Instantiate screen if given a class
      screen = screen.new if screen.respond_to?(:new)

      # Set parent, title & modal properties
      screen.parent_screen = self if screen.respond_to?("parent_screen=")
      screen.title = args[:title] if args[:title] && screen.respond_to?("title=")
      screen.modal = args[:modal] if args[:modal] && screen.respond_to?("modal=")

      # Wrap in a NavigationController?
      screen.add_navigation if args[:navigation] && screen.respond_to?(:add_navigation)

      # Return modified screen instance
      screen
    end

    def ensure_wrapper_controller_in_place(screen, args={})
      if !args[:modal] && screen.respond_to?(:navigation_controller=)
        screen.navigation_controller ||= navigation_controller
      end
    end

    def present_modal_view_controller(screen, animated)
      self.presentModalViewController(screen.main_controller, animated: animated)
    end

    def close_modal_screen(args = {})
      parent_screen.dismissViewControllerAnimated(args[:animated], completion: lambda {
        send_on_return(args)
      })
    end

    def close_navigation(args = {})
      if args[:to_screen] && args[:to_screen].is_a?(UIViewController)
        self.parent_screen = args[:to_screen]
        self.navigation_controller.popToViewController(args[:to_screen], animated: args[:animated])
      else
        self.navigation_controller.popViewControllerAnimated(args[:animated])
      end
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

    def add_navigation_controller
      self.navigation_controller = NavigationController.alloc.initWithRootViewController(self)
    end
  end
end