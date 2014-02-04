module MotionPrime
  class TabBarController < UITabBarController
    def self.new(screens, global_options = {})
      controller = alloc.init

      view_controllers = []

      screens.each_with_index do |options, index|
        if options.is_a?(Hash)
          screen = init_screen_with_options(global_options.deep_merge(options), tag: index)
        else
          screen = options
          screen.tabBarItem.tag = index
        end

        screen.send(:on_screen_load) if screen.respond_to?(:on_screen_load)
        screen.wrap_in_navigation if screen.respond_to?(:wrap_in_navigation)
        screen.tab_bar = controller.weak_ref if screen.respond_to?(:tab_bar=)
        view_controllers << screen.main_controller.strong_ref
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

    def dealloc
      Prime.logger.dealloc_message :tab_bar, self
      clear_instance_variables
      super
    end

    protected
      def self.init_screen_with_options(options, tag: tag)
        screen, title = options.delete(:screen), options.delete(:title)
        screen = Screen.create_with_options(screen, true, options).try(:weak_ref)
        title ||= screen.title
        image = extract_image_from_options(options, with_key: :image)
        screen.tabBarItem = UITabBarItem.alloc.initWithTitle title, image: image, tag: tag

        selected_image = extract_image_from_options(options, with_key: :selected_image)
        screen.tabBarItem.setSelectedImage(selected_image) if selected_image
        screen
      end

      def self.extract_image_from_options(options, with_key: key)
        image = options.delete(key)
        return unless image
        image = image.uiimage
        if options[:translucent] === false
          image = image.imageWithRenderingMode UIImageRenderingModeAlwaysOriginal
        end
        image
      end
  end
end