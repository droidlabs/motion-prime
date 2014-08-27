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
      page = page_for_index(index)
      set_view_controllers([page], animated, &block)
    end

    def reload_collection_data
      set_view_controllers(page_controller.viewControllers, false)
    end

    def set_view_controllers(controllers, animated = false, &completion)
      completion ||= proc{|a|}
      index = index_for_page(controllers.last)
      current_index = index_for_page(page_controller.viewControllers.last).to_i
      direction = current_index <= index ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
      page_controller.setViewControllers(controllers, direction: direction, animated: animated, completion: completion)
      page_did_set(index)
    end

    def page_did_set(index); end
    def page_will_set(index); end

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

    def current_page_id
      index_for_page(page_controller.viewControllers.last)
    end

    # Delegate
    def page_for_index(index)
      return nil if !index || data.length == 0 || index < 0 || index >= data.size
      @view_controllers.try(:[], index) || prepare_cell_section(data[index], index)
    end

    def index_for_page(view_controller)
      Array.wrap(@view_controllers).index(view_controller)
    end

    private
      def prepare_collection_cell_sections(sections)
        Array.wrap(sections.flatten).each_with_index do |section, index|
          prepare_cell_section(section, index)
        end
      end

      def prepare_cell_section(section, index)
        @view_controllers ||= []
        controller = MotionPrime::Screen.new
        controller.parent_screen = self.screen
        section.screen = controller.weak_ref
        controller.set_section :main, instance: section
        @view_controllers[index] = controller
      end
  end
end