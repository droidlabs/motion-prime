module MotionPrime
  module ScreenNavigationBarMixin
    def navigation_right_button
      navigationItem.rightBarButtonItem
    end

    def navigation_left_button
      navigationItem.leftBarButtonItem
    end

    def remove_navigation_right_button(args = {})
      navigationItem.setRightBarButtonItem(nil, animated: args[:animated])
    end

    def set_navigation_right_button(title, args = {}, &block)
      navigationItem.rightBarButtonItem = create_navigation_button(title, args, &block)
    end

    def set_navigation_right_buttons(options)
      navigationItem.rightBarButtonItems = options.map do |button_options|
        create_navigation_button(button_options.delete(:title), button_options)
      end
    end

    def set_navigation_left_button(title, args = {}, &block)
      navigationItem.leftBarButtonItem = create_navigation_button(title, args, &block)
    end

    def set_navigation_back_button(title, args = {})
      navigationItem.leftBarButtonItem = create_navigation_button(title, {action: :back}.merge(args))
    end

    # should be extracted to sidebar gem
    def set_navigation_back_or_menu(back_title = 'Back')
      if parent_screen.is_a?(PrimeResideMenu::SidebarContainerScreen)
        set_navigation_left_button 'Menu', image: 'images/navigation/menu_button.png', action: :show_sidebar
      else
        set_navigation_back_button back_title, icon: 'images/navigation/back_icon.png'
      end
    end

    def set_navigation_right_image(args = {})
      url = args.delete(:url)
      view = add_view(UIImageView, args)
      view.setImageWithURL NSURL.URLWithString(url), placeholderImage: nil
      navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(view)
    end

    def create_navigation_button(title, args = {}, &block)
      args[:style]  ||= UIBarButtonItemStylePlain
      args[:action] ||= block || nil
      # TODO: Find better place for this code, may be just create custom control
      if title.is_a?(UIButton)
        title.on :touch do
          args[:action].to_proc.call(args[:target] || self)
        end if args[:action]
        title.sizeToFit
        UIBarButtonItem.alloc.initWithCustomView(title)
      elsif args[:image]
        create_navigation_button_with_image(title, args)
      elsif args[:icon]
        create_navigation_button_with_title(title, args)
      else
        if args[:action].is_a?(Proc)
          create_navigation_button_with_title(title, args)
        else
          UIBarButtonItem.alloc.initWithTitle(title,
            style: args[:style], target: args[:target] || self, action: args[:action])
        end
      end
    end

    def create_navigation_button_with_title(title, args)
      image = args[:icon].uiimage if args[:icon]
      face = UIButton.buttonWithType UIButtonTypeCustom
      face.setImage(image, forState: UIControlStateNormal) if args[:icon]
      face.setTitle(title, forState: UIControlStateNormal)
      face.setTitleColor((args[:title_color] || :app_navigation_base).uicolor, forState: UIControlStateNormal)
      face.setContentHorizontalAlignment UIControlContentHorizontalAlignmentLeft
      face.sizeToFit
      face.on :touch do
        args[:action].to_proc.call(args[:target] || self)
      end if args[:action]
      UIBarButtonItem.alloc.initWithCustomView(face)
    end

    def create_navigation_button_with_image(title, args)
      image = args[:image].uiimage
      image = image.imageWithRenderingMode(2) if image && args[:tint_color].present?
      face = UIButton.buttonWithType UIButtonTypeCustom
      face.bounds = CGRectMake(0, 0, image.size.width, image.size.height)
      face.setImage image, forState: UIControlStateNormal
      face.setTintColor(args[:tint_color].uicolor) if args[:tint_color]
      face.setImageEdgeInsets(UIEdgeInsetsMake(0, args[:offset_x], 0, -args[:offset_x])) if args[:offset_x]
      face.on :touch do
        args[:action].to_proc.call(args[:target] || self)
      end if args[:action]
      UIBarButtonItem.alloc.initWithCustomView(face)
    end
  end
end