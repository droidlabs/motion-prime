module MotionPrime
  class TabBarController < UITabBarController
    def self.new(screens)
      controller = alloc.init

      view_controllers = []

      screens.each_with_index do |options, index|
        if options.is_a?(Hash)
          screen = init_screen_with_options(options, tag: index)
        else
          screen = options
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

    protected
      def self.init_screen_with_options(options, tag: tag)
        screen, image, title = options[:screen], options[:image], options[:title]
        screen = Screen.create_with_options(screen).try(:weak_ref)
        title ||= screen.title

        image = extract_image_from_options(options, with_key: :image)
        screen.tabBarItem = UITabBarItem.alloc.initWithTitle title, image: image, tag: tag

        selected_image = extract_image_from_options(options, with_key: :selected_image)
        screen.tabBarItem.setSelectedImage(selected_image) if selected_image
        screen
      end

      def self.extract_image_from_options(options, with_key: key)
        image = options[key]
        return unless image
        image = image.uiimage
        if options[:translucent] === false
          image = image.imageWithRenderingMode UIImageRenderingModeAlwaysOriginal
        end
        image
      end
  end
end