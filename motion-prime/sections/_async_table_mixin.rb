module Prime
  module AsyncTableMixin
    extend ::MotionSupport::Concern

    included do
      class_attribute :async_data_options
    end

    # Returns true if table section have enabled async data. False by defaul.
    #
    # @return [Boolean] is async data enabled.
    def async_data?
      self.class.async_data_options
    end

    def table_element_options
      options = super
      if async_data? && self.class.async_data_options.has_key?(:estimated_cell_height)
        options[:estimated_cell_height] = self.class.async_data_options[:estimated_cell_height]
      end
      options
    end

    # Reset async loaded table data and preloader queue.
    #
    # @return [Boolean] true
    def reset_data
      super # must be before to update fixed_table_data
      @async_loaded_data = async_data? ? fixed_table_data : nil
      Array.wrap(@preloader_queue).each { |queue| queue[:state] = :cancelled }
      @preloader_next_starts_from = nil
    end

    def height_for_index(table, index)
      section = cell_section_by_index(index)
      unless section
        Prime.logger.debug "could not find section with index #{index} for #{self.to_s}"
        return 0
      end
      preload_section_by_index(index)
      section.container_height
    end

    def render_cell(index, table)
      preload_sections_after(index)
      super
    end

    def on_async_data_loaded; end
    def on_queue_preloaded(queue_id, loaded_index); end
    def on_cell_section_preloaded(section, index); end

    # Preloads sections after rendering cell in current sheduled index or given index.
    # TODO: probably should be in separate class.
    #
    # @param from_index [NSIndexPath] Value of first index to load if current sheduled index not exists.
    # @return [NSIndexPath, Boolean] Index of next sheduled index.
    def preload_sections_after(from_index)
      return unless async_data?
      service = preloader_index_service
      load_limit = self.class.async_data_options.try(:[], :preload_cells_count)

      if @preloader_next_starts_from
        index_to_start_preloading = service.sum_index(@preloader_next_starts_from, load_limit ? -load_limit/2 : 0)
        # should we start preload based on index of rendered cell
        return false if service.compare_indexes(from_index, index_to_start_preloading) < 0
      end

      # adjust start/finish points based on current queues
      current_group = from_index.section
      left_to_load_in_group = cell_sections_for_group(current_group).count - from_index.row
      load_count = [left_to_load_in_group, load_limit].compact.min
      to_index = service.sum_index(from_index, load_count - 1)
      @preloader_next_starts_from = to_index

      Array.wrap(@preloader_queue).each do |queue_info|
        # cancelled and dealloc are left from prev data
        next unless [:in_progress, :completed].include?(queue_info[:state])
        # filter by current group
        next unless queue_info[:from_index].section == current_group
        # reject not started threads
        next if queue_info[:to_index].nil? && queue_info[:state] != :in_progress

        if from_index.row >= queue_info[:from_index].row
          from_index = NSIndexPath.indexPathForRow([from_index.row, queue_info[:to_index].try(:row).try(:+, 1), (queue_info[:target_index] if queue_info[:state] == :in_progress).try(:row).try(:+, 1)].compact.max, inSection: current_group)
        else
          to_index = NSIndexPath.indexPathForRow([to_index.row, queue_info[:from_index].try(:row).try(:-, 1)].compact.min, inSection: current_group)
        end
      end

      load_count = to_index.row - from_index.row + 1
      preload_sections_schedule_from(from_index, load_count) if load_count > 0
    end

    # Schedules preloading sections starting with given index with given limit.
    # TODO: probably should be in separate class.
    #
    # @param index [NSIndexPath] Value of first index to load.
    # @param load_count [Integer] Count of sections to load.
    # @return [Integer] Queue ID
    def preload_sections_schedule_from(index, load_count)
      service = preloader_index_service

      @preloader_queue ||= []

      # TODO: we do we need to keep screen ref too?
      queue_id = @preloader_queue.count

      allocate_strong_references(queue_id)

      @preloader_queue[queue_id] = {
        state: :in_progress,
        target_index: service.sum_index(index, load_count-1),
        from_index: index
      }

      BW::Reactor.schedule(queue_id) do |queue_id|
        result = load_count.times do |offset|
          if @preloader_queue[queue_id][:state] == :cancelled
            release_strong_references(queue_id)
            break
          end
          if allocated_references_released?
            @preloader_queue[queue_id][:state] = :dealloc
            release_strong_references(queue_id)
            break
          end

          if section = preload_section_by_index(index)
            on_cell_section_preloaded(section, index)
          end

          @preloader_queue[queue_id][:to_index] = index
          unless offset == load_count - 1
            index = service.sum_index(index, 1)
          end
          true
        end

        if result
          @preloader_queue[queue_id][:state] = :completed
          on_queue_preloaded(queue_id, index)
        end
        release_strong_references(queue_id)
      end
      queue_id
    end

    def preloader_index_service
      TableDataIndexes.new(@data)
    end

    private
      def set_table_data
        sections = load_sections_async
        prepare_table_cell_sections(sections)
        @data = sections
        reset_data_stamps
        @data
      end

      def load_sections_async
        @async_loaded_data || begin
          ref_key = allocate_strong_references
          BW::Reactor.schedule_on_main do
            @async_loaded_data = fixed_table_data
            @data = nil
            reload_table_data
            on_async_data_loaded
            release_strong_references(ref_key)
          end
          []
        end
      end

      def preload_section_by_index(index)
        section = cell_section_by_index(index)

        if section.create_elements && !section.container_element && async_data? # perform only if just loaded
          section.load_container_with_elements(container: container_element_options_for(index))
          section
        end
      end

      def create_section_elements; end

    module ClassMethods
      def inherited(subclass)
        super
        subclass.async_data_options = self.async_data_options.try(:clone)
      end

      def set_async_data_options(options = {})
        self.async_data_options = options
      end
    end
  end
end
