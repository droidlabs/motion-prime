motion_require './helpers/has_authorization'
motion_require './helpers/has_class_factory'
module MotionPrime
  class BaseAppDelegate
    include HasAuthorization

    attr_accessor :window

    def application(application, willFinishLaunchingWithOptions:opts)
      MotionPrime::Config.configure!
      MotionPrime::Styles.define!
      Prime.logger.info "Loading Prime application with env: #{Prime.env}"
      application.setStatusBarStyle UIStatusBarStyleLightContent
      application.setStatusBarHidden false
    end

    def application(application, didFinishLaunchingWithOptions:launch_options)
      on_load(application, launch_options)
      true
    end

    def application(application, didRegisterForRemoteNotificationsWithDeviceToken: token)
      on_apn_register_success(application, token)
    end
    def application(application, didFailToRegisterForRemoteNotificationsWithError: error)
      on_apn_register_fail(application, error)
    end

    def on_load(application, launch_options)
    end

    def on_apn_register_success(application, token)
    end

    def on_apn_register_fail(application, error)
    end

    def app_window
      self.app_delegate.window
    end

    def open_screen(screen, options = {})
      screen = prepare_screen_for_open(screen, options)
      if options[:root] || !self.window
        open_root_screen(screen, options)
      else
        open_content_screen(screen, options)
      end
    end

    def current_user
      @current_user ||= if defined?(User) && User.respond_to?(:current)
        User.current
      end
    end

    def reset_current_user
      user_was = @current_user
      @current_user = nil
      NSNotificationCenter.defaultCenter.postNotificationName(:on_current_user_reset, object: user_was)
    end

    private
      def prepare_screen_for_open(screen, options = {})
        Screen.create_with_options(screen, true, options)
      end

      def open_root_screen(screen, options = {})
        screen.send(:on_screen_load) if screen.respond_to?(:on_screen_load)
        screen.wrap_in_navigation if screen.respond_to?(:wrap_in_navigation)

        screen = screen.main_controller if screen.respond_to?(:main_controller)

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