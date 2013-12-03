module MotionPrime
  class TabBarController < UITabBarController
    
    def self.new(screens)
      controller = alloc.init

      view_controllers = []

      screens.each_with_index do |screen, index|
        screen.tabBarItem.tag = index
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
    end
  end
end