module MotionPrime
  class StaticFieldSection < Section
    include CellSectionMixin

    def form
      table
    end

    protected
      def elements_eval_object
        form
      end
  end
end
