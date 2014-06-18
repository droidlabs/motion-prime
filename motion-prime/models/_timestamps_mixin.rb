module MotionPrime
  module ModelTimestampsMixin
    extend ::MotionSupport::Concern

    def self.included(base)
      base.class_attribute :_timestamp_attributes
    end

    def save!
      time = Time.now
      trigger_timestamp(:save, time)
      trigger_timestamp(:create, time) if new_record?
      super
    end

    def trigger_timestamp(action_name, time)
      field = (_timestamp_attributes || {})[action_name]
      return unless field
      self.send(:"#{field}=", time)
    end
    
    module ClassMethods
      def timestamp_attributes(actions = nil)
        self._timestamp_attributes ||= {}
        actions ||= {save: :saved_at, create: :created_at}
        actions.each do |action_name, field|
          _timestamp_attributes[action_name.to_sym] = field
          self.attribute field, type: :time
        end
      end
    end
  end
end