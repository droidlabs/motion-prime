module MotionPrime
  class PageViewControllerElement < BaseElement
    def view_class
      "UIPageViewController"
    end

    def render!(options = {}, &block)
      builder = ViewBuilder.new(class_factory(view_class),  computed_options.merge(options))
      controller = builder.view
      ViewStyler.new(controller, CGRectZero, builder.options).apply

      first = section.collection_delegate.fetch_item(0)
      controller.setViewControllers([first], direction:UIPageViewControllerNavigationDirectionForward,
                                    animated:false, completion:lambda{|a|}) # completion:nil blows up!

      screen.addChildViewController(controller)
      screen.view.addSubview(controller.view)
      controller.didMoveToParentViewController(screen)
      screen.view.gestureRecognizers = controller.gestureRecognizers
      self.view = controller
    end
  end
end