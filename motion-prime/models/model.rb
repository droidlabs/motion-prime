motion_require '../helpers/has_authorization'
motion_require './_nano_bag_mixin'
motion_require './_finder_mixin'
motion_require './_base_mixin'
motion_require './_sync_mixin'
motion_require './_association_mixin'
motion_require './_dirty_mixin'
motion_require './store'
motion_require './store_extension'
module MotionPrime
  class Model < NSFNanoObject
    include MotionPrime::HasAuthorization
    include MotionPrime::HasNormalizer
    include MotionPrime::ModelBaseMixin
    include MotionPrime::ModelAssociationMixin
    include MotionPrime::ModelSyncMixin
    include MotionPrime::ModelFinderMixin
    include MotionPrime::ModelDirtyMixin
    include MotionPrime::ModelTimestampsMixin

    attribute :bag_key # need this as we use shared store; each nested resource must belong to parent bag
    attribute :id

    def errors
      @errors ||= Errors.new(self.weak_ref)
    end

    def set_errors(data)
      errors.track_changed do
        data.symbolize_keys.each do |key, error_messages|
          errors.set(key, error_messages, silent: true) if error_messages.present?
        end
      end
    end

    def dealloc
      Prime.logger.dealloc_message :model, self
      super
    end
  end
end