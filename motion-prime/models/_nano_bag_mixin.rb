motion_require './_finder_mixin'
module MotionPrime
  module NanoBagMixin
    include FilterMixin

    def self.included(base)
      base.class_eval do
        alias_method :saved, :savedObjects
        alias_method :unsaved, :unsavedObjects
        alias_method :removed, :removedObjects
        alias_method :size, :count
        alias_method :inflate, :inflateBag
        alias_method :deflate, :deflateBag
      end
    end

    def originalClassString
      'NSFNanoBag'
    end

    def changed?
      self.hasUnsavedChanges
    end

    # Return all objects in bag
    #
    # @return Array
    def to_a
      self.savedObjects.values + self.unsavedObjects.values
    end

    # Add an object or array of objects to bag
    #
    # @return self [Prime::Model]
    def add(object_or_array, options = {})
      error_ptr = Pointer.new(:id)
      options[:existed_ids] ||= filter_array(self.to_a, bag_key: self.key).inject({}) do |result, item|
        result.merge(item.id => item)
      end
      prepared = prepare_for_store(object_or_array, options)

      if object_or_array.is_a?(Array)
        self.addObjectsFromArray(prepared, error:error_ptr)
      else
        self.addObject(prepared, error:error_ptr)
      end
      raise StoreError, error_ptr[0].description if error_ptr[0]
      self
    end
    alias_method :+, :add
    alias_method :<<, :add

    def prepare_for_store(object, options = {})
      if object.is_a?(Array)
        object.map { |entity| prepare_for_store(entity, options) }.compact
      else
        object.bag_key = self.key
        if object.id.present? && options[:existed_ids].include?(object.id)
          if options[:silent_validation]
            return
          elsif options[:replace]
            replace = options[:existed_ids][object.id]
            replace.delete
            delete_key(replace.key)
            object
          else
            raise StoreError, "duplicated item added `#{object.class_name_without_kvo}` with `id` = #{object.id}"
          end
        end
        object
      end
    end

    # Remove object from bag with key
    #
    # @param key [String] a key or array of keys
    # @return self [Prime::Model]
    def delete_key(key)
      if key.is_a?(Array)
        self.removeObjectsWithKeysInArray(key)
      else
        self.removeObjectWithKey(key)
      end
      self
    end

    # Remove an object or array of objects from bag
    #
    # @param items [Array<Prime::Model>, Prime::Model] model or array of models to remove
    # @return self
    def delete(object_or_array)
      error_ptr = Pointer.new(:id)
      if object_or_array.is_a?(Array)
        self.removeObjectsInArray(object_or_array, error: error_ptr)
      else
        self.removeObject(object_or_array, error_ptr)
      end
      raise StoreError, error_ptr[0].description if error_ptr[0]
      self
    end
    alias_method :-, :delete

    # Clear content of the bag
    #
    # @return self
    def delete_all
      bag_copy = to_a.clone
      # this removes childrens from model
      delete(self.to_a)
      # this removes collection from db
      bag_copy.each(&:delete)
      self
    end
    alias_method :clear, :delete_all


    def store=(store, retry_count = 0)
      store.addObject(self, error: nil)
    rescue Exception => e
      sleep(0.1)
      if retry_count == 3
        raise StoreError, e.description
      else
        send(:store=, store, retry_count + 1)
      end
    end

    def save
      self.performSelectorOnMainThread :save!, withObject: nil, waitUntilDone: true
    end

    def save!
      self.store ||= MotionPrime::Store.shared_store
      self.store.save_interval = savedObjects.count + unsavedObjects.count
      error_ptr = Pointer.new(:id)
      result = self.saveAndReturnError(error_ptr)
      raise StoreError, error_ptr[0].description if error_ptr[0]
      self.store.save_interval = 1
      result
    end

    def reload
      error_ptr = Pointer.new(:id)
      result = self.reloadBagWithError(error_ptr)
      raise StoreError, error_ptr[0].description if error_ptr[0]
      result
    end

    def undo
      error_ptr = Pointer.new(:id)
      result = self.undoChangesWithError(error_ptr)
      raise StoreError, error_ptr[0].description if error_ptr[0]
      result
    end
  end

  Bag = ::NSFNanoBag
end

class NSFNanoBag
  include MotionPrime::ModelFinderMixin::ClassMethods
  include MotionPrime::NanoBagMixin
end