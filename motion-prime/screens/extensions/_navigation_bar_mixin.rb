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

    def set_navigation_right_button(title, args = {})
      navigationItem.rightBarButtonItem = create_navigation_button(title, args)
    end

    def set_navigation_left_button(title, args = {})
      navigationItem.leftBarButtonItem = create_navigation_button(title, args)
    end

    def set_navigation_back_button(title, args = {})
      navigationItem.leftBarButtonItem = create_navigation_button(title, {action: :back}.merge(args))
    end

    def set_navigation_back_or_menu(back_title = 'Back')
      if parent_screen.is_a?(MotionPrime::SidebarContainerScreen)
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

    def create_navigation_button(title, args = {})
      args[:style]  ||= UIBarButtonItemStylePlain
      args[:target] = (args[:target] || self).weak_ref
      args[:action] ||= nil
      # TODO: Find better place for this code, may be just create custom control
      if args[:image]
        image = args[:image].uiimage
        face = UIButton.buttonWithType UIButtonTypeCustom
        face.bounds = CGRectMake(0, 0, image.size.width, image.size.height)
        face.setImage image, forState: UIControlStateNormal
        face.on :touch do
          args[:action].to_proc.call(self)
        end
        UIBarButtonItem.alloc.initWithCustomView(face)
      elsif args[:icon]
        image = args[:icon].uiimage
        face = UIButton.buttonWithType UIButtonTypeCustom
        face.setImage(image, forState: UIControlStateNormal)
        face.setTitle(title, forState: UIControlStateNormal)
        face.bounds = CGRectMake(0, 0, 100, 60)
        face.setContentHorizontalAlignment UIControlContentHorizontalAlignmentLeft
        face.on :touch do
          args[:action].to_proc.call(self)
        end
        UIBarButtonItem.alloc.initWithCustomView(face)
      else
        UIBarButtonItem.alloc.initWithTitle(title,
          style: args[:style], target: args[:target], action: args[:action])
      end
    end
  end
end