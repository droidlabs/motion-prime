module MotionPrime
  class TabBarController < UITabBarController
    def self.new(screens)
      controller = alloc.init

      view_controllers = []

      screens.each_with_index do |screen, index|
        if screen.is_a?(Hash)
          screen, image, title = screen[:screen], screen[:image], screen[:title]
          title ||= screen.title
          image = image.uiimage if image
          screen.tabBarItem = UITabBarItem.alloc.initWithTitle title, image: image, tag: index
        else
          screen.tabBarItem.tag = index
        end

        screen.send(:on_screen_load) if screen.respond_to?(:on_screen_load)
        screen.wrap_in_navigation if screen.respond_to?(:wrap_in_navigation)
        screen.tab_bar = controller if screen.respond_to?(:tab_bar=)
        view_controllers << screen.main_controller
      end

      controller.viewControllers = view_controllers
      controller
    end
    
    def open_tab(tab)
      controller = viewControllers[tab]
      if controller
        self.selectedViewController = controller
      end
      controller
    end
  end
end