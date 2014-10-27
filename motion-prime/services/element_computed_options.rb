module MotionPrime
  class ElementComputedOptions < BaseComputedOptions
    include HasStyleChainBuilder

    attr_reader :element, :section, :styles, :screen
    def initialize(element, options = {})
      super()

      @element = element.weak_ref
      @section = element.section
      @screen = element.screen
      @block = element.block
      @_has_section = !section.nil? # #present? cause error in blank.rb (undefined method #empty?)

      block_options = compute_block_options || {}
      raw_options = element.options.except(:screen, :name, :block, :view_class).merge(block_options)
      compute_style_options(raw_options)
      raw_options = Styles.for(styles).deep_merge(raw_options)
      self.merge!(raw_options)
    end

    def normalizer
      element
    end

    def receiver
      section ? section.send(:elements_eval_object) : element
    end

    def compute_block_options
      element.normalize_value(@block, section) if @block
    end

    def compute_style_options(*style_sources)
      @styles = []
      if element.cell_section?
        # FIXME: sometimes cause error: undefined method `style_suffixes' for instance of BaseSection's subclass
        begin
          suffixes = section.style_suffixes if section.respond_to?(:style_suffixes)
        rescue => e
          Prime.logger.debug(e)
          suffixes = nil
        end
        @styles += compute_cell_style_options(style_sources, Array.wrap(suffixes))
      end

      mixins = []
      custom_styles = []
      style_sources.each do |source|
        if source_mixins = source.delete(:mixins)
          mixins += Array.wrap(element.normalize_object(source_mixins, receiver))
        end
        if source_styles = source.delete(:styles)
          custom_styles += Array.wrap(element.normalize_object(source_styles, receiver))
        end
      end
      # styles got from mixins option
      @styles += mixins.map{ |m| :"_mixin_#{m}" }

      # don't use present? here, it's slower, while this method should be very fast
      if section && section.name && section.name != '' && element.name && element.name != ''
        # using for base sections
        @styles << [section.name, element.name].join('_').to_sym
      end

      # custom style (from options or block options), using for TableViews as well
      @styles += custom_styles
      # pp(@view_class.to_s + @styles.inspect); puts()
      @styles
    end

    def compute_cell_style_options(style_sources, additional_suffixes)
      base_styles = {common: [], specific: []}
      suffixes = {common: [], specific: []}
      all_styles = []

      # following example in Prime::TableSection#cell_section_styles
      # form element/cell: <base|user>_form_field, <base|user>_form_string_field, user_form_field_email
      # table element/cell: <base|categories>_table_cell, categories_table_title
      if section.section_styles
        section.section_styles.each { |type, values| base_styles[type] += values }
      end
      if element.view_name != 'base' && !element.cell_element?
        # form element: _input
        # table element: _image
        suffixes[:common] << element.view_name.to_sym
        additional_suffixes.each do |additional_suffix|
          suffixes[:common] << [element.view_name, additional_suffix].join('_').to_sym
        end
      end
      if element.name && element.name.to_s != element.view_name
        # form element: _input
        # table element: _icon
        suffixes[:specific] << element.name.to_sym
        additional_suffixes.each do |additional_suffix|
          suffixes[:specific] << [element.name, additional_suffix].join('_').to_sym
        end
      end
      # form cell: base_form_field, base_form_string_field
      # form element: base_form_field_string_field, base_form_string_field_text_field, base_form_string_field_input
      # table cell: base_table_cell
      # table element: base_table_cell_image
      common_styles = if suffixes[:common].any?
        build_styles_chain(base_styles[:common], suffixes.values.flatten)
      elsif suffixes[:specific].any?
        build_styles_chain(base_styles[:common], suffixes[:specific])
      elsif element.cell_element?
        base_styles[:common]
      end
      all_styles += Array.wrap(common_styles)
      # form cell: user_form_field, user_form_string_field, user_form_field_email
      # form element: user_form_field_text_field, user_form_string_field_text_field, user_form_field_email_text_field
      # table cell: categories_table_cell, categories_table_title
      # table element: categories_table_cell_image, categories_table_title_image
      specific_base_common_suffix_styles = if suffixes[:common].any?
        build_styles_chain(base_styles[:specific], suffixes[:common])
      elsif suffixes[:specific].empty? && element.cell_element?
        base_styles[:specific]
      end
      all_styles += Array.wrap(specific_base_common_suffix_styles)
      # form element: user_form_field_input, user_form_string_field_input, user_form_field_email_input
      # table element: categories_table_cell_icon, categories_table_title_icon
      all_styles += build_styles_chain(base_styles[:specific], suffixes[:specific])
      all_styles
    end
  end
end
