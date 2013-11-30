motion_require '../helpers/has_normalizer'
motion_require '../helpers/has_style_chain_builder'
module MotionPrime
  class BaseElement
    # MotionPrime::BaseElement is container for UIView class elements with options.
    # Elements are located inside Sections

    include ::MotionSupport::Callbacks
    include HasNormalizer
    include HasStyleChainBuilder

    attr_accessor :options, :section, :name,
                  :view_class, :view, :view_name, :styles, :screen
    delegate :observing_errors?, :has_errors?, :errors_observer_fields, :observing_errors_for, to: :section, allow_nil: true
    define_callbacks :render

    def initialize(options = {})
      @options = options
      @section = options[:section]
      @name = options[:name]
      @block = options[:block]
      @view_class = options[:view_class] || "UIView"
      @view_name = self.class_name_without_kvo.demodulize.underscore.gsub('_element', '')
    end

    def render(options = {}, &block)
      @screen = options[:to]
      run_callbacks :render do
        render!(&block)
      end
    end

    def render!(&block)
      @view = screen.add_view view_class.constantize, computed_options, &block
      @view
    end

    # Lazy-computing options
    def computed_options
      compute_options! if @computed_options.blank?
      @computed_options
    end

    def compute_options!
      @computed_options ||= {}
      block_options = compute_block_options || {}
      compute_style_options(options, block_options)
      @computed_options.merge!(options.except(:section, :name, :block, :view_class))
      @computed_options.merge!(block_options)
      normalize_options(@computed_options, section, %w[text placeholder font title_label padding padding_left padding_right min_width min_outer_width max_width max_outer_width width left right])
    end

    # Compute options sent inside block, e.g.
    # element :button do
    #   {name: model.name}
    # end
    def compute_block_options
      section.send(:instance_exec, self, &@block) if @block
    end

    def compute_style_options(*style_sources)
      @styles = []
      base_styles = {common: [], specific: []}
      suffixes = {common: [@view_name.to_sym, name.try(:to_sym)].compact, specific: []}

      if section
        cell_section = section.is_a?(BaseCellSection)
        if cell_section
          section.section_styles.each { |type, values| base_styles[type] += values }
        end
        if section.respond_to?(:observing_errors?) && observing_errors? && has_errors?
          suffixes[:common] += [:"#{name}_with_errors", :"#{@view_name}_with_errors"]
        end
      end

      # common + specific base - common suffixes
      @styles += build_styles_chain(base_styles[:common], suffixes[:common])
      @styles << [section.name, name].compact.join('_').to_sym if section
      @styles += build_styles_chain(base_styles[:specific], suffixes[:common])
      # specific base - specific suffixes
      @styles += build_styles_chain(base_styles[:specific], suffixes[:specific])
      if cell_section && section.table.present?
        @styles << [section.table.name, section.cell_type, section.name, name].compact.join('_').to_sym
      end
      # custom style (from options or block options)
      custom_styles = style_sources.map do |source|
        normalize_object(source.delete(:styles), section)
      end.compact.flatten
      @styles += custom_styles
      # puts @view_class.to_s + @styles.inspect, ''
      @computed_options.merge!(style_options)
    end

    def style_options
      Styles.for(styles)
    end

    def update_with_options(new_options = {})
      options.merge!(new_options)
      compute_options!
      view.try(:removeFromSuperview)
      @view = nil
      render(to: screen)
    end

    def hide
      view.hidden = true
    end

    def show
      view.hidden = false
    end

    class << self
      def factory(type, options = {})
        class_name = "#{type.classify}Element"
        options.merge!({view_class: "UI#{type.classify}"})
        if MotionPrime.const_defined?(class_name)
          "MotionPrime::#{class_name}".constantize.new(options)
        else
          self.new(options)
        end
      end
      def before_render(method_name)
        set_callback :render, :before, method_name
      end
      def after_render(method_name)
        set_callback :render, :after, method_name
      end
    end
  end
end