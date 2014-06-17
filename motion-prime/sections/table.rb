motion_require './table/refresh_mixin'
motion_require './table/table_delegate'

module MotionPrime
  class TableSection < AbstractCollectionSection
    include TableSectionRefreshMixin
    include HasSearchBar

    class_attribute :group_header_options, :pull_to_refresh_block, :pull_to_refresh_options

    attr_accessor :group_header_sections, :group_header_options
    after_render :init_pull_to_refresh
    delegate :init_pull_to_refresh, to: :collection_delegate

    # Add cells to table view and reload table view.
    #
    # @param cell sections [Prime::Section, Array<Prime::Section>] cells which will be added to table view.
    # @return [Boolean] true
    def add_cell_sections(sections, index = nil)
      prepare_collection_cell_sections(sections)
      @data ||= []
      index ||= @data.count
      @data.insert([index, @data.count].min, *sections)
      reload_collection_data
    end

    # Delete cells from table data and remove them from table view with animation.
    #
    # @param cell sections [Prime::Section, Array<Prime::Section>] cells which will be removed from table view.
    # @return [Array<NSIndexPath>] index paths of removed cells.
    def delete_cell_sections(sections, &block)
      paths = []
      Array.wrap(sections).each do |section|
        index = index_for_cell_section(section)
        next Prime.logger.debug("Delete cell section: `#{section.name}` is not in the list") unless index
        paths << index
        delete_from_data(index)
      end
      if paths.any?
        UIView.animate(duration: 0, after: block) do
          collection_view.beginUpdates
          collection_view.deleteRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimationLeft)
          collection_view.endUpdates
        end
      end
      paths
    end

    # Reloads cells with animation, executes given block before reloading.
    #
    # @param cell sections [Prime::Section, Array<Prime::Section>] cells which will be updated.
    # @param around callback [Proc] Callback which will be executed before reloading.
    # @return [Array<NSIndexPath>] index paths of reloaded cells.
    def reload_cell_sections(sections, &block)
      paths = []
      Array.wrap(sections).each_with_index do |section, counter|
        index = index_for_cell_section(section)
        next Prime.logger.debug("Reload section: `#{section.name}` is not in the list") unless index
        paths << index
        block.call(section, index, counter)
        deque_cell(section, at: index) # deque cached
        section.reload
      end
      self.performSelectorOnMainThread(:reload_cells, withObject: paths, waitUntilDone: false)
      paths
    end

    # Forces TableView to reload Rows by index paths
    #
    # @param [Array<NSIndexPath>] index paths of cells to reload.
    def reload_cells(*paths)
      collection_view.reloadRowsAtIndexPaths(Array.wrap(paths), withRowAnimation: UITableViewRowAnimationFade)
      collection_view.reloadData # do not use reload_collection_data (due to async_form_mixin)
    end

    # Changes height of cells with animation.
    #
    # @param cell sections [Prime::Section, Array<Prime::Section>] cells which will be updated.
    # @param height [Integer, Array<Integer>] new height of all cells, or height for each cell.
    # @return [Array<NSIndexPath>] index paths of removed cells.
    def resize_cell_sections(sections, height)
      reload_cell_sections(sections) do |section, index, counter|
        container_height = height.is_a?(Array) ? height[counter] : height
        section.container_options[:height] = container_height
      end
    end

    # Delete section from data at index
    #
    # @param index [NSIndexPath] index of cell which will be removed from table data.
    def delete_from_data(index)
      if flat_data?
        delete_from_flat_data(index)
      else
        delete_from_grouped_data(index)
      end
    end

    # Get index path for cell section
    #
    # @param section [Prime::Section] cell section.
    # @return index [NSIndexPath] index of cell section.
    def index_for_cell_section(section)
      if flat_data?
        row = @data.try(:index, section)
        NSIndexPath.indexPathForRow(row, inSection: 0) if row
      else
        (@data || []).each_with_index do |cell_sections, group|
          row = cell_sections.index(section)
          return NSIndexPath.indexPathForRow(row, inSection: group) if row
        end
      end
    end

    def collection_styles_base
      base_styles = [:base_table]
      base_styles << :"#{type}_with_sections" unless flat_data?
      base_styles
    end

    def collection_delegate
      @collection_delegate ||= TableDelegate.new(section: self)
    end

    def table_element_options
      collection_element_options.merge({
        style: (UITableViewStyleGrouped unless flat_data?)
      })
    end

    def render_collection
      self.collection_element = screen.table_view(table_element_options)
    end

    def render_cell(index)
      section = cell_section_by_index(index)
      element = section.container_element || section.init_container_element(container_element_options_for(index))

      view = element.render do
        section.render
      end

      on_cell_render(view, index)
      view
    end

    def render_header(group)
      return unless options = self.group_header_options.try(:[], group)
      self.group_header_sections[group] ||= FormHeaderSection.new(options.merge(screen: screen, collection_section: self.weak_ref))
    end

    def header_section_for_group(group)
      self.group_header_sections ||= []
      self.group_header_sections[group] || render_header(group)
    end

    def has_many_sections?
      group_header_options.present? || data.try(:first).is_a?(Array)
    end

    def flat_data?
      !has_many_sections?
    end

    def cell_sections_for_group(section)
      flat_data? ? data : data[section]
    end

    # Table View Delegate
    # ---------------------

    def number_of_groups
      has_many_sections? ? data.count : 1
    end

    def header_cell_in_group(group)
      return unless header = header_section_for_group(group)

      reuse_identifier = "header_#{group}_#{@header_stamp}"
      cached = collection_view.dequeueReusableHeaderFooterViewWithIdentifier(reuse_identifier)
      return cached if cached.present?

      styles = cell_section_styles(header).values.flatten
      wrapper = MotionPrime::BaseElement.factory(:table_header,
        screen: screen,
        styles: styles,
        parent_view: collection_view,
        reuse_identifier: reuse_identifier,
        section: header.weak_ref
      )
      wrapper.render do |container_view, container_element|
        header.container_element = container_element
        header.render
      end
    end

    def height_for_header_in_group(group)
      header_section_for_group(group).try(:container_height) || 0
    end

    private
      def delete_from_flat_data(index)
        @data[index.row] = nil
        @data.delete_at(index.row)
      end

      def delete_from_grouped_data(index)
        @data[index.section][index.row] = nil
        @data[index.section].delete_at(index.row)
      end

      def cached_cell(index)
        collection_view.dequeueReusableCellWithIdentifier(cell_name(index)) || begin
          section = cell_section_by_index(index)
          section.create_elements
          cell = section.try(:cell)
          if cell.try(:superview)
            Prime.logger.error "cell already exists: #{section.name}: #{cell}"
            nil
          end
        end
      end

      def deque_cell(section, at: index)
        collection_view.dequeueReusableCellWithIdentifier(cell_name(index))
        section.cell.try(:removeFromSuperview)
        set_data_stamp(section.object_id)
      end

      def set_header_stamp
        @header_stamp = Time.now.to_i
      end

      def reset_data_stamps
        super
        set_header_stamp
      end

    class << self
      def inherited(subclass)
        super
        subclass.group_header_options = self.group_header_options.try(:clone)
      end

      def async_collection_data(options = {})
        self.send :include, Prime::AsyncTableMixin
        self.set_async_data_options options
      end

      def group_header(name, options)
        options[:name] = name
        self.group_header_options ||= []
        section = options.delete(:id)
        self.group_header_options[section] = options
      end

      def pull_to_refresh(options = {}, &block)
        self.pull_to_refresh_options = options
        self.pull_to_refresh_block = block
      end
    end
  end
end