motion_require './helpers/has_authorization'
motion_require './helpers/has_class_factory'
module MotionPrime
  class BaseAppDelegate
    include HasAuthorization

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
      screen = Screen.create_with_options(screen, true, options)
      if sidebar_option = options.delete(:sidebar)
        sidebar_option = :sidebar if sidebar_option == true
        sidebar = Screen.create_with_options(sidebar_option, false, {})
        open_with_sidebar(screen, sidebar, options)
      elsif options[:root] || !self.window
        open_root_screen(screen)
      else
        open_content_screen(screen)
      end
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

    private
      def open_root_screen(screen)
        screen.send(:on_screen_load) if screen.respond_to?(:on_screen_load)
        screen.wrap_in_navigation if screen.respond_to?(:wrap_in_navigation)

        screen = screen.main_controller if screen.respond_to?(:main_controller)

        self.window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
        self.window.rootViewController = screen
        self.window.makeKeyAndVisible
        screen
      end
    
      def open_content_screen(screen)
        if sidebar?
          sidebar_container.content_controller = screen
        else
          open_root_screen(screen)
        end
      end

      def open_with_sidebar(content, sidebar, options={})
        self.sidebar_container = SidebarContainerScreen.new(sidebar, content, options)
        self.sidebar_container.delegate = self
        open_root_screen(sidebar_container)
      end

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