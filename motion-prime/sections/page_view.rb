motion_require './page_view/page_view_delegate'

module MotionPrime
  class PageViewSection < AbstractCollectionSection
    attr_accessor :page_controller
    before_render :render_collection
    after_render :set_first_page

    def collection_styles_base
      :base_page_view
    end

    def collection_delegate
      @collection_delegate ||= PageViewDelegate.new(section: self)
    end

    def page_element_options
      collection_element_options
    end

    def render_collection
      self.collection_element = screen.page_view_controller(page_element_options)
    end

    def set_first_page
      set_page(0)
    end

    def set_page(index, animated = false, &block)
      block ||= proc{|a|}
      page = page_for_index(index)
      page_controller.setViewControllers([page], direction:UIPageViewControllerNavigationDirectionForward, animated:animated, completion: block)
    end

    def reload_collection_data
      page_controller.setViewControllers(page_controller.viewControllers, direction:UIPageViewControllerNavigationDirectionForward, animated:false, completion:proc{|a|})
    end

    def add_pages(sections, follow = false)
      @data += Array.wrap(sections)
      if follow
        page_index = data.count - 1
        set_page(page_index, true) do |finished|
          BW::Reactor.schedule_on_main { set_page(page_index, false) }
        end
      else
        reload_collection_data
      end
    end

    # Delegate
    def page_for_index(index)
      return nil if !index || data.length == 0 || index < 0 || index >= data.size
      @view_controllers ||= []
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

    def index_for_page(view_controller)
      Array.wrap(@view_controllers).index(view_controller)
    end
  end
end