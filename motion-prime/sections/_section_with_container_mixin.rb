module MotionPrime
  module SectionWithContainerMixin
    extend ::MotionSupport::Concern

    included do
      class_attribute :container_element_options
    end

    def container_view
      container_element.try(:view)
    end

    def init_container_element(options = {})
      if @_creating_container
        sleep 0.01
        return @container_element ? @container_element : init_container_element(options)
      end
      @_creating_container = true
      @container_element ||= begin
        options.merge!({
          screen: screen,
          section: self.weak_ref,
          has_drawn_content: true
        })
        container_element_options = self.class.container_element_options.clone
        options = (container_element_options || {}).deep_merge(options)
        type = options.delete(:type)
        MotionPrime::BaseElement.factory(type, options)
      end
      @_creating_container = false
      @container_element
    end

    def load_container_with_elements(options = {})
      init_container_element(options[:container] || {})
      # FIXME: does not work for grid sections
      @container_element.preload_options
      compute_element_options(options[:elements] || {})

      if respond_to?(:prerender_elements_for_state) && prerender_enabled?
        prerender_elements_for_state(:normal)
      end
    end

    private
      def compute_element_options(options = {})
        self.elements.values.each do |element|
          element.preload_options
        end
      end


    module ClassMethods
      def container_element(options)
        self.container_element_options = options
      end
    end
  end
end
