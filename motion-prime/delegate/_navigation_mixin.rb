module MotionPrime
  module DelegateNavigationMixin
    def open_screen(screen, options = {})
      screen = prepare_screen_for_open(screen, options)
      if options[:root] || !self.window
        open_root_screen(screen, options)
      else
        open_content_screen(screen, options)
      end
    end

    private
      def prepare_screen_for_open(screen, options = {})
        Screen.create_with_options(screen, true, options)
      end

      def open_root_screen(screen, options = {})
        screen.send(:on_screen_load) if screen.respond_to?(:on_screen_load)
        screen.wrap_in_navigation if screen.respond_to?(:wrap_in_navigation)

        screen = screen.main_controller.strong_ref if screen.respond_to?(:main_controller)

        self.window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
        if options[:animated]
          UIView.transitionWithView self.window,
                  duration: 0.5,
                   options: UIViewAnimationOptionTransitionFlipFromLeft,
                animations: proc { self.window.rootViewController = screen },
                completion: nil
        else
          self.window.rootViewController = screen
        end
        self.window.makeKeyAndVisible
        screen
      end

      def open_content_screen(screen, options = {})
        open_root_screen(screen)
      end
  end
end