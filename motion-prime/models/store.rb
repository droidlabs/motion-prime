motion_require '../config/base'
module MotionPrime
  class Store
    def self.create(type = nil, path = nil)
      error_ptr = Pointer.new(:id)
      case type || MotionPrime::Config.model.store_type.to_sym
      when :memory
        store = NSFNanoStore.createAndOpenStoreWithType(NSFMemoryStoreType, path: nil, error: error_ptr)
      when :temporary, :temp
        store = NSFNanoStore.createAndOpenStoreWithType(NSFTemporaryStoreType, path: nil, error: error_ptr)
      when :persistent, :file
        path ||= begin
          documents_path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]
          documents_path + "/nano_#{Prime.env.to_s}.db"
        end
        store = NSFNanoStore.createAndOpenStoreWithType(NSFPersistentStoreType, path: path, error: error_ptr)
      else
        raise StoreError.new("unexpected store type (#{type}), must be one of: :memory, :temporary or :persistent")
      end

      raise StoreError, error_ptr[0].description if error_ptr[0]
      store
    end

    def self.connect!(type = nil)
      self.shared_store = create(type)
    end

    def self.connect(type = nil)
      connect!(type) unless connected?
    end

    def self.connected?
      !!shared_store
    end

    def self.disconnect
      self.shared_store = nil
    end

    def self.shared_store
      @shared_store
    end

    def self.shared_store=(store)
      @shared_store = store
    end

    def self.debug=(debug)
      NSFSetIsDebugOn(debug)
    end
  end
end