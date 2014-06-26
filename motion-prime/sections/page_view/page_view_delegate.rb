module MotionPrime
  class PageViewDelegate
    include DelegateMixin
    attr_accessor :collection_section

    def initialize(options)
      self.collection_section = options[:section].try(:weak_ref)
      @_section_info = collection_section.to_s
      @section_instance = collection_section.to_s
    end

    def dealloc
      Prime.logger.dealloc_message :collection_delegate, @_section_info
      super
    end

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
        collection_section.reload_collection_data
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
        collection_section.set_view_controllers(viewControllers, true)
        page_view_controller.doubleSided = true
        return UIPageViewControllerSpineLocationMid
      end
    end

    def pageViewController(pvc, didFinishAnimating: finished, previousViewControllers: previous_view_controllers, transitionCompleted: completed)
      if completed
        index = collection_section.index_for_page(collection_section.page_controller.viewControllers.last)
        collection_section.page_did_set(index)
      end
    end

    def pageViewController(pvc, willTransitionToViewControllers: pending_view_controllers)
      index = collection_section.index_for_page(pending_view_controllers.last)
      collection_section.page_will_set(index)
    end
  end
end