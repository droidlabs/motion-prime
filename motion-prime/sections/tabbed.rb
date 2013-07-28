module MotionPrime
  class TabbedSection < BaseSection
    class_attribute :tabs_options
    attr_accessor :tab_pages

    element :control, type: :segmented_control,
      styles: [:base_segmented_control], items: proc { tab_control_items }

    after_render :render_tab_controls
    after_render :render_tab_pages

    def tab_control_items
      self.class.tabs_options.values.map{ |o| o[:name] }
    end

    def render_tab_pages
      @tab_pages = []
      self.class.tabs_options.each do |key, options|
        section_class = options[:page_section].classify
        page = "::#{section_class}Section".constantize.new(model: model)
        page.render(to: screen)
        @tab_pages << page
      end
    end

    def render_tab_controls
      element(:control).view.addTarget(
        self, action: :on_click, forControlEvents: UIControlEventValueChanged
      )
    end

    # on clicn to control
    # @param UISegemtedControl control
    def on_click(*control)
      @tab_pages.each_with_index do |page, i|
        page.hide if control.selectedSegment != i
      end
      @tab_pages[control.selectedSegment].show
    end

    class << self
      def tab(id, options = {})
        options[:name] = id.to_s.titleize
        options[:id] = id

        self.tabs_options ||= {}
        self.tabs_options[id] = options
      end
    end
  end
end