motion_require './helpers/has_authorization'
module MotionPrime
  class BaseAppDelegate
    include MotionPrime::HasAuthorization

    attr_accessor :window, :sidebar_container

    def application(application, willFinishLaunchingWithOptions:opts)
      application.setStatusBarStyle UIStatusBarStyleLightContent
      application.setStatusBarHidden false
    end

    def application(application, didFinishLaunchingWithOptions:launch_options)
      on_load(application, launch_options)
      true
    end

    def app_window
      self.app_delegate.window
    end

    def open_screen(screen, options = {})
      screen = create_tab_bar(screen) if screen.is_a?(Array)
      if options[:sidebar]
        open_with_sidebar(screen, options.delete(:sidebar), options)
      elsif options[:root] || !self.window
        open_root_screen(screen)
      else
        open_content_screen(screen)
      end
    end

    # TODO: move to private methods
    def open_root_screen(screen)
      close_current_screens
      screen.send(:on_screen_load) if screen.respond_to?(:on_screen_load)
      screen.wrap_in_navigation if screen.respond_to?(:wrap_in_navigation)

      screen = screen.main_controller if screen.respond_to?(:main_controller)

      self.window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = screen
      self.window.makeKeyAndVisible
      screen
    end

    # TODO: move to private methods
    def open_content_screen(screen)
      if sidebar?
        close_current_screens
        sidebar_container.content_controller = screen
      else
        open_root_screen(screen)
      end
    end

    # TODO: move to private methods
    def open_with_sidebar(content, sidebar, options={})
      self.sidebar_container = SidebarContainerScreen.new(sidebar, content, options)
      self.sidebar_container.delegate = self
      open_root_screen(sidebar_container)
    end

    def sidebar?
      self.window && self.window.rootViewController.is_a?(SidebarContainerScreen)
    end

    def show_sidebar
      sidebar_container.show_sidebar
    end

    def hide_sidebar
      sidebar_container.hide_sidebar
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

    def close_screens(screens)
      Array.wrap(screens).each { |screen| screen.on_destroy if screen.respond_to?(:on_destroy) }
    end

    private
      def close_current_screens
        return unless self.window

        screens = if sidebar? && sidebar_container.content_controller.is_a?(UINavigationController)
          sidebar_container.content_controller.childViewControllers
        elsif sidebar?
          sidebar_container.content_controller
        else
          window.rootViewController
        end
        close_screens(screens)
      end

      def create_tab_bar(screens)
        MotionPrime::TabBarController.new(screens)
      end
  end
end