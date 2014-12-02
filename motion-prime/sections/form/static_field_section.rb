module MotionPrime
  class StaticFieldSection < Section
    include CellSectionMixin

    def form
      collection_section
    end

    def clear_observers; end

    protected
      def elements_eval_object
        form
      end
  end
end
