module MotionPrime
  module ModelSyncMixin
    extend ::MotionSupport::Concern

    def self.included(base)
      base.class_attribute :_sync_url
      base.class_attribute :_updatable_attributes
      base.class_attribute :_associations
    end

    # Get normalized sync url of this Prime::Model
    #
    # @param method [Symbol] http method
    # @return url [String] url to use in model sync
    def sync_url(method = :get, options = {})
      url = self.class.sync_url
      url = url.call(method, self, options) if url.is_a?(Proc)
      normalize_sync_url(url)
    end

    # Get normalized sync url of associated Prime::Model
    #
    # @param key [Symbol] association name
    # @return url [String] url to use in model association sync
    def association_sync_url(key, options)
      url = options[:sync_url]
      url = url.call(self) if url.is_a?(Proc)
      normalize_sync_url(url)
    end

    # Destroy model on server and delete on local
    #
    # @param block [Proc] block to be executed after destroy
    # @return self[Prime::Model] deleted model.
    def destroy(&block)
      use_callback = block_given?
      api_client.delete(sync_url(:delete)) do
        block.call() if use_callback
      end
      delete
    end

    # Fetch model from server and save on local
    #
    def fetch!(options = {}, &block)
      fetch(options.merge(save: true), &block)
    end

    # Fetch model from server
    #
    # @param options [Hash] fetch options
    # @option options [Symbol] :method Http method to calculate url, `:get` by default
    # @option options [Boolean] :associations Also fetch associations
    # @option options [Boolean] :save Save model after fetch
    # @param block [Proc] block to be executed after fetch
    def fetch(options = {}, &block)
      use_callback = block_given?
      method = options[:method] || :get
      url = sync_url(method, options)

      will_fetch_model = !url.blank?
      will_fetch_associations = !options.has_key?(:associations) || options[:associations]
      will_fetch_associations = false unless has_associations_to_fetch?

      fetch_with_url url, options do |data, status_code|
        save if options[:save]
        block.call(data, status_code, data) if use_callback && !will_fetch_associations
      end if will_fetch_model

      fetch_associations(options) do |data, status_code|
        # run callback only if it wasn't run on fetch
        block.call(data, status_code, data) if use_callback
      end if will_fetch_associations
    end

    # Update on server and save response on local
    #
    def update!(options = {}, &block)
      update(options.merge(save_response: true), &block)
    end

    # Update on server
    # @param options [Hash] update options
    # @option options [Symbol] :method Http method to calculate url, by default  `:post` for new record and `:put` for existing
    # @param block [Proc] block to be executed after update
    def update(options = {}, &block)
      use_callback = block_given?

      method = options[:method] || (persisted? ? :put : :post)
      url = sync_url(method, options)
      will_update_model = !url.blank?

      update_with_url url, options do |data, status_code|
        block.call(data, status_code, data) if use_callback
      end if will_update_model
    end

    # Fetch model from server using url
    #
    # @param url [String] url to fetch
    # @param block [Proc] block to be executed after fetch
    def fetch_with_url(url, options = {}, &block)
      use_callback = block_given?
      api_client.get(url) do |data, status_code|
        if data.present?
          fetch_with_attributes(data, save_associations: options[:save], &block)
        end
        block.call(data, status_code, data) if use_callback
      end
    end

    # Update on server using url
    #
    # @param url [String] url to update
    # @param block [Proc] block to be executed after update
    def update_with_url(url, options = {}, &block)
      use_callback = block_given?
      filtered_attributes = filtered_updatable_attributes(options)

      attributes = attributes_to_post_data(model_name, filtered_attributes)

      post_data = options[:params_root] || {}
      post_data.merge!(attributes)

      method = options[:method] || (persisted? ? :put : :post)
      api_client.send(method, url, post_data, options) do |data, status_code|
        save_response = !options.has_key?(:save_response) || options[:save_response]
        if save_response && status_code.to_s =~ /20\d/ && data.is_a?(Hash)
          set_attributes_from_response(data)
          save
        end
        block.call(data, status_code, data) if use_callback
      end
    end

    def set_attributes_from_response(data)
      self.id ||= data.delete('id')
      fetch_with_attributes(data)
    end

    # Assign model attributes, using fetch. Differenct between assign_attributes and fetch_with_attributes is
    # ths you can create method named fetch_:attribute and it will be used to assign attribute only on fetch.
    #
    # @example
    #   class User < Prime::Model
    #     attribute :created_at
    #     def fetch_created_at(value)
    #       self.created_at = Date.parse(value)
    #     end
    #   end
    #   user = User.new
    #   user.fetch_with_attributes(created_at: '2007-03-01T13:00:00Z')
    #   user.created_at # => 2007-03-01 13:00:00 UTC
    #
    # @params attributes [Hash] attributes to be assigned
    # @params options [Hash] options
    # @option options [Boolean] :save_associations Save included to hash associations
    # @return model [Prime::Model] the model
    def fetch_with_attributes(attrs, options = {})
      track_changed_attributes do
        attrs.each do |key, value|
          if respond_to?(:"fetch_#{key}")
            self.send(:"fetch_#{key}", value)
          elsif has_association?(key) && (value.is_a?(Hash) || value.is_a?(Array))
            should_save = options[:save_associations]
            fetch_association_with_attributes(key, value, save: should_save)
          elsif respond_to?(:"#{key}=")
            self.send(:"#{key}=", value)
          end
        end
      end
      self
    end

    def associations
      @associations ||= (self.class._associations || {}).clone
    end

    def associations_to_fetch
      @associations_to_fetch ||= associations.select { |key, v| fetch_association?(key) }
    end

    def fetch_associations(sync_options = {}, &block)
      use_callback = block_given?
      associations_to_fetch.keys.each_with_index do |key, index|
        if use_callback && associations.count - 1 == index
          fetch_association(key, sync_options, &block)
        else
          fetch_association(key, sync_options)
        end
      end
    end

    def has_associations_to_fetch?
      associations_to_fetch.present?
    end

    def has_association?(key)
      !associations[key.to_sym].nil?
    end

    def fetch_association?(key)
      options = associations[key.to_sym]
      return false if options[:if] && !options[:if].to_proc.call(self)
      association_sync_url(key, options).present?
    end

    def fetch_association(key, sync_options = {}, &block)
      return unless fetch_association?(key)
      options = associations[key.to_sym]
      if options[:type] == :many
        fetch_has_many(key, options, sync_options, &block)
      else
        fetch_has_one(key, options, sync_options, &block)
      end
    end

    def fetch_association_with_attributes(key, data, sync_options = {})
      options = associations[key.to_sym]
      return unless options
      if options[:type] == :many
        fetch_has_many_with_attributes(key, data || [], sync_options)
      else
        fetch_has_one_with_attributes(key, data || {}, sync_options)
      end
    end

    def fetch_has_many(key, options = {}, sync_options = {}, &block)
      use_callback = block_given?
      NSLog("SYNC: started sync for #{key} in #{self.class_name_without_kvo}")
      api_client.get association_sync_url(key, options) do |response, status_code|
        data = options[:sync_key] && response ? response[options[:sync_key]] : response
        if data
          fetch_has_many_with_attributes(key, data, sync_options)
          NSLog("SYNC: finished sync for #{key} in #{self.class_name_without_kvo}")
          block.call(data, status_code, response) if use_callback
        else
          NSLog("SYNC ERROR: failed sync for #{key} in #{self.class_name_without_kvo}")
          block.call(data, status_code, response) if use_callback
        end
      end
    end

    def fetch_has_many_with_attributes(key, data, sync_options = {})
      old_collection = self.send(key)
      model_class = key.classify.constantize
      self.store.save_interval = data.present? ? data.count : 1
      # Update/Create existing records
      track_changed_attributes do
        data.each do |attributes|
          model = old_collection.detect{ |model| model.id == attributes[:id]}
          unless model
            model = model_class.new
            self.send(:"#{key}_bag") << model
          end
          model.fetch_with_attributes(attributes, save_associations: sync_options[:save])
          model.save if sync_options[:save] && model.has_changed?
        end
        old_collection.each do |old_model|
          model = data.detect{ |model| model[:id] == old_model.id}
          unless model
            old_model.delete
          end
        end
      end
      save if sync_options[:save] && has_changed?
      self.store.save_interval = 1
    end

    def fetch_has_one(key, options = {}, &block)
      use_callback = block_given?
      NSLog("SYNC: started sync for #{key} in #{self.class_name_without_kvo}")
      api_client.get association_sync_url(key, options) do |response, status_code|
        data = options.has_key?(:sync_key) ? response[options[:sync_key]] : response
        if data.present?
          fetch_has_one_with_attributes(key, data, save_associations: sync_options[:save])
          block.call(data, status_code, response) if use_callback
        else
          NSLog("SYNC ERROR: failed sync for #{key} in #{self.class_name_without_kvo}")
          block.call(data, status_code, response) if use_callback
        end
      end
    end

    def fetch_has_one_with_attributes(key, data, sync_options = {})
      track_changed_attributes do
        model = self.send(key)
        unless model
          model = key.classify.constantize.new
          self.send(:"#{key}_bag") << model
        end
        model.fetch_with_attributes(data)
        model.save if sync_options[:save]
      end
      save if sync_options[:save] && has_changed?
    end

    def filtered_updatable_attributes(options = {})
      slice_attributes = options[:updatable_attributes].map(&:to_sym) if options.has_key?(:updatable_attributes)
      updatable_attributes = self.class.updatable_attributes

      if updatable_attributes.blank?
        return slice_attributes ? attributes_hash.slice(*slice_attributes) : attributes_hash
      end

      updatable_attributes = updatable_attributes.slice(*slice_attributes) if slice_attributes
      updatable_attributes.inject({}) do |hash, (key, options)|
        next hash if options[:if] && !send(options[:if])
        value = if block = options[:block]
          block.call(self, hash)
        else
          info[key]
        end

        hash[key] = value
        hash
      end
    end

    def normalize_sync_url(url)
      normalize_object(url).to_s.gsub(':id', id.to_s)
    end

    def attributes_to_post_data(root_name, attributes)
      result = {:_files => [], root_name => attributes}

      result[root_name].each do |name, field_attrs|
        next unless field_attrs.is_a?(Hash)
        files = Array.wrap(field_attrs.delete(:_files)).map do |file|
          file[:name].insert(0, "#{root_name}[#{name}]")
          file
        end
        result[:_files] += files
      end
      result
    end

    module ClassMethods
      def fetch_all_with_attributes(data)
        data.map do |attrs|
          item = self.new
          item.fetch_with_attributes(attrs)
          item
        end
      end

      def new(data = {}, options = {})
        model = super
        if fetch_attributes = options[:fetch_attributes]
          model.fetch_with_attributes(fetch_attributes)
        end
        model
      end

      def sync_url(url = nil, &block)
        if url || block_given?
          self._sync_url = url || block
        else
          self._sync_url
        end
      end

      def updatable_attributes(*attrs)
        return self._updatable_attributes if attrs.blank?
        attrs.each do |attribute|
          updatable_attribute(attribute)
        end
      end

      def updatable_attribute(attribute, options = {}, &block)
        options[:block] = block if block_given?
        self._updatable_attributes ||= {}
        self._updatable_attributes[attribute] = options
      end
    end
  end
end