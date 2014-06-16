module MotionPrime
  class PageViewDelegate
    include DelegateMixin
    attr_accessor :collection_section

    def initialize(options)
      self.collection_section = options[:section].try(:weak_ref)
      @section_instance = collection_section.to_s
    end

    # def dealloc
    #   pp 'Deallocating page_view_delegate for ', @section_instance
    #   super
    # end

    def viewControllerAtIndex(index, storyboard:storyboard)
      collection_section.page_for_index(index)
    end

    def pageViewController(pvc, viewControllerBeforeViewController:vc)
      index = collection_section.index_for_page(vc)
      collection_section.page_for_index(index - 1)
    end

    def pageViewController(pvc, viewControllerAfterViewController:vc)
      index = collection_section.index_for_page(vc)
      collection_section.page_for_index(index + 1)
    end

    def presentationCountForPageViewController(controller)
      collection_section.data.size
    end

    def pageViewController(pvc, spineLocationForInterfaceOrientation:orientation)
      page_view_controller = collection_section.page_controller

      current = page_view_controller.viewControllers[0]
      is_portrait = UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft ||
                    UIDevice.currentDevice.orientation == UIDeviceOrientationPortraitUpsideDown ||
                    UIDevice.currentDevice.orientation == UIDeviceOrientationUnknown
      if is_portrait
        page_view_controller.setViewControllers([current], direction:UIPageViewControllerNavigationDirectionForward, animated:true, completion:lambda{|a|})
        page_view_controller.doubleSided = false
        return UIPageViewControllerSpineLocationMin
      else
        index = collection_section.index_for_page(current)
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