module MotionPrime
  class TabbedSection < BaseSection
    class_attribute :tabs_options, :tabs_default
    attr_accessor :tab_pages

    element :control, type: :segmented_control,
      styles: [:base_segmented_control], items: proc { tab_control_items }

    before_render :render_tab_pages
    after_render :render_tab_controls

    def tab_options
      self.class.tabs_options
    end

    def tab_control_items
      tab_options.values.map{ |o| o[:name] }
    end

    def render_tab_pages
      @tab_pages = []
      tab_options.each do |key, options|
        section_class = options[:page_section].classify
        page = "::#{section_class}Section".constantize.new(model: model)
        page.render(to: screen)
        @tab_pages << page
      end
    end

    def render_tab_controls
      default = self.class.tabs_default || 0
      control = element(:control).view
      control.addTarget(
        self, action: :on_click, forControlEvents: UIControlEventValueChanged
      )
      control.setSelectedSegmentIndex(default)
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
        self.tabs_default = tabs_options.length if options[:default]
        self.tabs_options[id] = options
      end
    end
  end
end