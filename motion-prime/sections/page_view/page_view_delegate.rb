module MotionPrime
  class PageViewDelegate
    include DelegateMixin
    attr_accessor :collection_section

    def initialize(options)
      self.collection_section = options[:section].try(:weak_ref)
      @section_instance = collection_section.to_s
      @view_controllers = {}
    end

    # def dealloc
    #   pp 'Deallocating page_view_delegate for ', @section_instance
    #   super
    # end

    def data
      collection_section.data
    end

    def fetch_item(index)
      if @view_controllers[index]
        @view_controllers[index]
      else
        controller = MotionPrime::Screen.new
        section = data[index]
        section.screen = controller.weak_ref
        controller.set_section :main, instance: section
        @view_controllers[index] = controller
      end
    end

    def viewControllerAtIndex(index, storyboard:storyboard)
      return nil if data.length == 0 || index >= data.size
      fetch_item(index)
    end

    def indexOfViewController(viewController)
      @view_controllers.key(viewController)
    end

    def pageViewController(pvc, viewControllerBeforeViewController:vc)
      index = indexOfViewController(vc)
      return if !index || index <= 0
      fetch_item(index - 1)
    end


    def pageViewController(pvc, viewControllerAfterViewController:vc)
      index = indexOfViewController(vc)
      return if !index || index >= data.size - 1
      fetch_item(index + 1)
    end

    def presentationCountForPageViewController(controller)
      data.size
    end

    def pageViewController(pvc, spineLocationForInterfaceOrientation:orientation)
      page_view_controller = collection_section.collection_view
      current = page_view_controller.viewControllers[0]
      is_portrait = UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft ||
                    UIDevice.currentDevice.orientation == UIDeviceOrientationPortraitUpsideDown ||
                    UIDevice.currentDevice.orientation == UIDeviceOrientationUnknown
      if is_portrait
        page_view_controller.setViewControllers([current], direction:UIPageViewControllerNavigationDirectionForward, animated:true, completion:lambda{|a|})
        page_view_controller.doubleSided = false
        return UIPageViewControllerSpineLocationMin
      else
        index = indexOfViewController(current)
        if (index==0 || index%2==0)
          next_vc = pageViewController(page_view_controller, viewControllerAfterViewController: current)
          viewControllers = [current, next_vc]
        else
          prev_vc = pageViewController(page_view_controller, viewControllerBeforeViewController: current)
          viewControllers = [prev_vc, current]
        end
        page_view_controller.setViewControllers(viewControllers, direction:UIPageViewControllerNavigationDirectionForward, animated:true, completion:lambda{|a|})
        page_view_controller.doubleSided = true
        return UIPageViewControllerSpineLocationMid
      end
    end
  end
end