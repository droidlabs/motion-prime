module MotionPrime
  module ModelDirtyMixin
    extend ::MotionSupport::Concern

    def self.included(base)
      base.class_attribute :_changed_attributes
    end

    def track_changed_attributes(&block)
      @_changed_attributes ||= {}
      old_attrs = self.info.clone
      result = block.call
      new_attrs = self.info.clone
      new_attrs.each do |key, value|
        if value != old_attrs[key] && ! @_changed_attributes.has_key?(key.to_s)
          @_changed_attributes[key.to_s] = old_attrs[key]
        end
      end
      result
    end

    def has_changed?(key = nil)
      @_changed_attributes ||= {}
      if key
        @_changed_attributes.has_key?(key.to_s)
      else
        @_changed_attributes.present?
      end
    end
  end
end
