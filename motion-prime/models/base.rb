motion_require '../helpers/has_authorization'
motion_require './bag.rb'
motion_require './finder.rb'
motion_require './model.rb'
motion_require './store.rb'
motion_require './sync.rb'
motion_require './association.rb'
motion_require './store_extension.rb'
module MotionPrime
  class BaseModel < NSFNanoObject
    include MotionPrime::HasAuthorization
    include MotionPrime::ModelMethods
    include MotionPrime::ModelAssociationMethods
    include MotionPrime::ModelSyncMethods

    extend MotionPrime::ModelClassMethods
    extend MotionPrime::ModelFinderMethods
    extend MotionPrime::ModelAssociationClassMethods
    extend MotionPrime::ModelSyncClassMethods

    def errors
      @errors ||= Errors.new(self)
    end
  end
end