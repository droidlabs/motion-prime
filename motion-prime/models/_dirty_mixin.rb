module MotionPrime
  module ModelDirtyMixin
    extend ::MotionSupport::Concern

    def self.included(base)
      base.class_attribute :_changed_attributes
    end

    def track_changed_attributes(&block)
      @_tracking_changes = true
      @_changed_attributes ||= {}
      old_attrs = self.info.clone
      result = block.call
      new_attrs = self.info.clone
      new_bags = self._bags.clone
      new_attrs.each do |key, value|
        if value != old_attrs[key] && !@_changed_attributes.has_key?(key.to_s)
          @_changed_attributes[key.to_s] = old_attrs[key]
        end
      end
      new_bags.each do |key, value|
        if value.key != old_attrs[key] && !@_changed_attributes.has_key?(key.to_s)
          @_changed_attributes[key.to_s] = old_attrs[key]
        end
      end
      @_tracking_changes = false
      result
    end

    def changed_attributes
      @_changed_attributes ||= {}
    end

    def reset_changed_attributes
      @_changed_attributes = {}
    end

    # Return true if model was changed
    #
    # @param key [Symbol,String] (not required) will return result only for that attribute if specified
    # @return result [Boolean] result
    def has_changed?(key = nil)
      if key
        changed_attributes.has_key?(key.to_s)
      else
        changed_attributes.present?
      end
    end

    def save!
      super
      reset_changed_attributes
      self
    end

    # Reverts model changes and returns saved version
    #
    # @return model [MotionPrime::Model] reloaded model
    def reload
      changed_attributes.each do |key, value|
        self.info[key] = value
      end
      reset_changed_attributes
      self
    end
  end
end
