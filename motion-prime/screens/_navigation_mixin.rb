module MotionPrime
  module ScreenNavigationMixin
    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def show_sidebar
      app_delegate.show_sidebar
    end

    def hide_sidebar
      app_delegate.hide_sidebar
    end

    def open_screen(screen, args = {})
      if args[:modal] || has_navigation?
        screen = setup_screen_for_open(screen, args)
        screen.send(:on_screen_load) if screen.respond_to?(:on_screen_load)
        args[:animated] = args.has_key?(:animated) ? args[:animated] : true
        if args[:modal] || !has_navigation?
          open_screen_modal(screen, args)
        else
          open_screen_navigational(screen, args)
        end
      else
        app_delegate.open_screen(screen.main_controller)
      end
    end

    def close_screen(args = {})
      args[:animated] = args.has_key?(:animated) ? args[:animated] : true
      # Pop current view, maybe with arguments, if in navigation controller
      if modal?
        close_screen_modal(args)
      elsif has_navigation?
        close_screen_navigational(args)
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

    def ensure_wrapper_controller_in_place(args = {})
      # Wrap in a NavigationController?
      if wrap_in_navigation? && !args[:modal]
        add_navigation_controller
      end
    end

    private
      def setup_screen_for_open(screen, args = {})
        # Instantiate screen if given a class
        screen = screen.new if screen.respond_to?(:new)

        # Set parent, title & modal properties
        screen.parent_screen = self if screen.respond_to?("parent_screen=")
        screen.title = args[:title] if args[:title] && screen.respond_to?("title=")
        screen.modal = args[:modal] if args[:modal] && screen.respond_to?("modal=")

        # Return modified screen instance
        screen
      end

      def open_screen_modal(screen, args)
        self.presentModalViewController(screen.main_controller, animated: args[:animated])
      end

      def open_screen_navigational(screen, args = {})
        navigation_controller.pushViewController(screen, animated: args[:animated])
      end

      def close_screen_modal(args = {})
        parent_screen.dismissViewControllerAnimated(args[:animated], completion: lambda {
          send_on_return(args)
        })
      end

      def close_screen_navigational(args = {})
        if args[:to_screen] && args[:to_screen].is_a?(UIViewController)
          self.parent_screen = args[:to_screen]
          self.navigation_controller.popToViewController(args[:to_screen], animated: args[:animated])
        else
          self.navigation_controller.popViewControllerAnimated(args[:animated])
        end
        send_on_return(args)
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