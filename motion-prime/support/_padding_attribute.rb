module MotionPrime
  module SupportPaddingAttribute
    extend ::MotionSupport::Concern

    included do
      attr_accessor :paddingLeft, :paddingRight, :paddingTop, :paddingBottom, :padding
    end

    module ClassMethods
      def default_padding_top
        0
      end

      def default_padding_left
        0
      end

      def default_padding_right
        0
      end

      def default_padding_bottom
        0
      end
    end

    def padding_left
      self.paddingLeft || self.padding || self.class.default_padding_left
    end

    def padding_right
      self.paddingRight || self.padding || self.class.default_padding_right
    end

    def padding_top
      self.paddingTop || self.padding || self.class.default_padding_top
    end

    def padding_bottom
      self.paddingBottom || self.padding || self.class.default_padding_bottom
    end

    def padding_insets
      UIEdgeInsetsMake(padding_top, padding_left, padding_bottom, padding_right)
    end

    def apply_padding(rect)
      return unless apply_padding?
      apply_padding!(rect)
    end

    def apply_padding!(rect)
      raise "requires implementation"
    end

    def apply_padding?
      ![padding_top, padding_left, padding_right, padding_bottom].all?(&:zero?)
    end
  end
end