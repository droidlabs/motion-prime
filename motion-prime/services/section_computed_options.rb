module MotionPrime
  class SectionComputedOptions < BaseComputedOptions
    attr_reader :section, :styles

    def initialize(section, options = {})
      super()
      @section = section.weak_ref

      raw_options = section.class.container_options.try(:clone) || {}
      raw_options.deep_merge!(section.options[:container] || {})

      if section_styles = section.section_styles
        container_options_from_styles = Styles.for(section_styles.values.flatten)[:container]
        if container_options_from_styles.present?
          raw_options = container_options_from_styles.deep_merge(raw_options)
        end
      end
      self.merge!(raw_options)
    end

    def normalizer
      section
    end

    def receiver
      section.send(:elements_eval_object)
    end
  end
end
