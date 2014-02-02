module MotionPrime
  module ScreenNavigationMixin
    # Open screen as child for current screen if current screen have navigation or new screen is modal.
    # Otherwise will create screen using app_delegate.open_screen.
    # Available options:
    #   animated: open screen with animation.
    #   modal: open screen as model

    # @param screen [MotionPrime::Screen] Screen to be opened
    # @param args [Hash] Options for opening screen
    # @return [MotionPrime::Screen]
    def open_screen(screen, args = {})
      screen = setup_screen_for_open(screen, args)
      screen.send(:on_screen_load) if screen.respond_to?(:on_screen_load)
      args[:animated] = args.has_key?(:animated) ? args[:animated] : true
      if args[:modal] || !has_navigation?
        open_screen_modal(screen, args.merge(modal: true))
      else
        open_screen_navigational(screen, args)
      end
      screen
    end

    # @return screen [Prime::Screen] screen appearing after close
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

    def send_on_return
      if parent_screen && parent_screen.respond_to?(:on_return)
        parent_screen.send(:on_return)
      end
    end

    def send_on_leave
      if respond_to?(:on_leave)
        on_leave
      end
    end

    def wrap_in_navigation?
      options.fetch(:navigation, true)
    end

    def wrap_in_navigation
      if wrap_in_navigation?
        wrap_in_navigation!
      end
    end

    def has_navigation?
      !navigation_controller.nil?
    end

    def navigation_controller
      @navigation_controller ||= self.navigationController.try(:weak_ref)
    end

    def navigation_controller=(val)
      @navigation_controller = val.try(:weak_ref)
    end

    private
      def setup_screen_for_open(screen, args = {})
        screen = self.class.create_with_options(screen, true, args)
        screen.parent_screen = self if screen.respond_to?("parent_screen=")
        screen
      end

      def open_screen_modal(screen, args)
        screen.modal = true if screen.respond_to?("modal=")
        self.presentModalViewController(screen.main_controller, animated: args[:animated])
        send_on_leave
      end

      def open_screen_navigational(screen, args = {})
        navigation_controller.pushViewController(screen, animated: args[:animated])
        send_on_leave
      end

      # @return screen [Prime::Screen] screen appearing after close
      def close_screen_modal(args = {})
        parent_screen.dismissViewControllerAnimated(args[:animated], completion: lambda {
          send_on_return
        })
        parent_screen
      end

      # @return screen [Prime::Screen] screen appearing after close
      def close_screen_navigational(args = {})
        if args[:to_screen] && args[:to_screen].is_a?(UIViewController)
          self.parent_screen = args[:to_screen]

          screens = self.navigation_controller.childViewControllers
          self.navigation_controller.popToViewController(args[:to_screen], animated: args[:animated])
          result = self.parent_screen
        else
          if args[:to_root]
            self.navigation_controller.popToRootViewControllerAnimated(args[:animated])
            result = self.navigation_controller.childViewControllers.first
          else
            self.navigation_controller.popViewControllerAnimated(args[:animated])
            result = self.navigation_controller.childViewControllers.last
          end
        end
        send_on_return
        result
      end

      def wrap_in_navigation!
        self.navigation_controller = UINavigationController.alloc.initWithRootViewController(self)
      end
  end
end