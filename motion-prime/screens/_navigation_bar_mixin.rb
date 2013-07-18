module MotionPrime
  module ScreenNavigationBarMixin
    def navigation_right_button
      navigationItem.rightBarButtonItem
    end

    def navigation_left_button
      navigationItem.leftBarButtonItem
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

    def create_navigation_button(title, args = {})
      args[:style]  ||= UIBarButtonItemStylePlain
      args[:target] ||= self
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
        button = UIBarButtonItem.alloc.initWithCustomView(face)
        button
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
        button = UIBarButtonItem.alloc.initWithCustomView(face)
        button
      else
        UIBarButtonItem.alloc.initWithTitle(title,
            style: args[:style], target: args[:target], action: args[:action])
      end
    end
  end
end