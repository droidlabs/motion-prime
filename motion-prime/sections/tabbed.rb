module MotionPrime
  class TabbedSection < BaseSection
    # MotionPrime::TabbedSection is base class for building tabbed views.

    # == Basic Sample
    # class MySection < MotionPrime::TabbedSection
    #   tab :info, default: true, page_section: :info_tab
    #   tab :map, page_section: :map_tab
    #   # page_section options will be converted to section class and added to section.
    #   # e.g. in this sample: InfoTabSection.new(screen: screen, model: model).render
    # end
    #
    include MotionPrime::HasNormalizer

    class_attribute :tabs_options, :tabs_default, :tabs_indexes
    attr_accessor :tab_pages

    element :control, type: :segmented_control,
      styles: [:base_segmented_control], items: proc { tab_control_items }

    after_render :render_tab_pages
    after_render :render_tab_controls

    def tab_options
      @tab_options ||= normalize_options(self.class.tabs_options.clone)
    end

    def tab_control_items
      @tab_control_items ||= tab_options.values.map{ |o| o[:name] }
    end

    def tab_default
      @tab_default ||= self.class.tabs_default || 0
    end

    # Make tab button disabled by index
    # @param Fixnum index
    def disable_at(index)
      toggle_at(index, false)
    end

    # Make tab button enabled by index
    # @param Fixnum index
    def enable_at(index)
      toggle_at(index, true)
    end

    # Toggle tab button activity by index
    # @param [Fixnum, String] index or tab id
    # @param Boolean value
    def toggle_at(index, value)
      if index.is_a?(Symbol)
        index = self.class.tabs_indexes[index]
      end
      view(:control).setEnabled value, forSegmentAtIndex: index
    end

    # on click to segment tab
    # @param UISegemtedControl control
    def on_click(*control)
      show_at_index(control.selectedSegment)
    end

    def show_at_index(index)
      @tab_pages.each_with_index do |page, i|
        page.hide if index != i
      end
      view(:control).setSelectedSegmentIndex index
      @tab_pages[index].show
    end

    def show_by_key(key)
      id = self.class.tabs_indexes[key]
      show_at_index(id)
    end

    def tab_page(key)
      id = self.class.tabs_indexes[key]
      tab_pages[id]
    end

    def set_title(key, title)
      id = self.class.tabs_indexes[key]
      view(:control).setTitle(title, forSegmentAtIndex: id)
    end

    class << self
      def tab(id, options = {})
        options[:name] ||= id.to_s.titleize
        options[:id] = id

        self.tabs_indexes ||= {}
        self.tabs_indexes[id] = tabs_indexes.length
        self.tabs_default = tabs_indexes.length - 1 if options[:default]

        self.tabs_options ||= {}
        self.tabs_options[id] = options
      end
    end

    private
      def render_tab_pages
        self.tab_pages = []
        index = 0
        tab_options.each do |key, options|
          section_class = options[:page_section].classify
          page = "::#{section_class}Section".constantize.new(screen: screen, model: model)
          page.render
          page.hide if index != tab_default
          self.tab_pages << page
          index += 1
        end
      end

      def render_tab_controls
        control = element(:control).view
        control.addTarget(
          self, action: :on_click, forControlEvents: UIControlEventValueChanged
        )
        control.setSelectedSegmentIndex(tab_default)
      end
  end
end