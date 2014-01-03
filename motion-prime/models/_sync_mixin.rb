module MotionPrime
  module ModelSyncMixin
    extend ::MotionSupport::Concern
    
    def self.included(base)
      base.class_attribute :_sync_url
      base.class_attribute :_updatable_attributes
      base.class_attribute :_associations
    end

    def sync_url(method = :get, options = {})
      url = self.class.sync_url
      url = url.call(method, self, options) if url.is_a?(Proc)
      normalize_sync_url(url)
    end

    # destroy on server and delete on local
    def destroy(&block)
      use_callback = block_given?
      api_client.delete(sync_url(:delete)) do
        block.call() if use_callback
      end
      delete
    end

    # fetch from server and save on local
    def fetch!(options = {}, &block)
      fetch(options.merge(save: true), &block)
    end

    # fetch from server
    def fetch(options = {}, &block)
      use_callback = block_given?
      method = options[:method] || :get
      url = sync_url(method, options)

      will_fetch_model = !url.blank?
      will_fetch_associations = !options.has_key?(:associations) || options[:associations]

      fetch_with_url url do |data, status_code|
        save if options[:save]
        block.call(data, status_code, data) if use_callback
      end if will_fetch_model

      fetch_associations(options) do |data, status_code|
        # run callback only if it wasn't run on fetch
        block.call(data, status_code, data) if use_callback && !will_fetch_model
      end if will_fetch_associations
    end

    # update on server and save response on local
    def update!(options = {}, &block)
      update(options.merge(save_response: true), &block)
    end

    # update on server
    def update(options = {}, &block)
      use_callback = block_given?

      method = options[:method] || (persisted? ? :put : :post)
      url = sync_url(method, options)
      will_update_model = !url.blank?

      update_with_url url, options do |data, status_code|
        block.call(data, status_code, data) if use_callback
      end if will_update_model
    end

    # fetch from server using url
    def fetch_with_url(url, &block)
      use_callback = block_given?
      api_client.get(url) do |data, status_code|
        fetch_with_attributes(data, &block) if data.present?
        block.call(data, status_code, data) if use_callback
      end
    end

    # update on server using url
    def update_with_url(url, options = {}, &block)
      use_callback = block_given?
      filtered_attributes = filtered_updatable_attributes(options)

      post_data = options[:params_root] || {}
      post_data[:files] = {}
      filtered_attributes.delete(:files).each do |file_name, file|
        post_data[:files][[model_name, file_name].join] = file
      end
      post_data[model_name] = filtered_attributes

      method = options[:method] || (persisted? ? :put : :post)
      api_client.send(method, url, post_data) do |data, status_code|
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

    # set attributes, using fetch
    def fetch_with_attributes(attrs)
      attrs.each do |key, value|
        if respond_to?(:"fetch_#{key}")
          self.send(:"fetch_#{key}", value)
        elsif respond_to?(:"#{key}=")
          self.send(:"#{key}=", value)
        end
      end
      self
    end

    def fetch_associations(sync_options = {}, &block)
      use_callback = block_given?
      associations = self.class._associations || {}
      association_keys = associations.keys.select { |key| fetch_association?(key) }

      association_keys.each_with_index do |key, index|
        if use_callback && associations.count - 1 == index
          fetch_association(key, sync_options, &block)
        else
          fetch_association(key, sync_options)
        end
      end
    end

    def fetch_association?(key)
      options = self.class._associations[key]
      return if options[:if] && !options[:if].to_proc.call(self)
      options[:sync_url].present?
    end

    def fetch_association(key, sync_options = {}, &block)
      return unless fetch_association?(key)
      options = self.class._associations[key]
      if options[:type] == :many
        fetch_has_many(key, options, sync_options, &block)
      else
        fetch_has_one(key, options, sync_options, &block)
      end
    end

    def fetch_has_many(key, options = {}, sync_options = {}, &block)
      old_collection = self.send(key)

      use_callback = block_given?
      NSLog("SYNC: started sync for #{key} in #{self.class_name_without_kvo}")
      api_client.get normalize_sync_url(options[:sync_url]) do |response, status_code|
        data = options[:sync_key] && response ? response[options[:sync_key]] : response
        if data
          # Update/Create existing records
          data.each do |attributes|
            model = old_collection.detect{ |model| model.id == attributes[:id]}
            unless model
              model = key.classify.constantize.new
              self.send(:"#{key}_bag") << model
            end
            model.fetch_with_attributes(attributes)
            model.save if sync_options[:save]
          end
          old_collection.each do |old_model|
            model = data.detect{ |model| model[:id] == old_model.id}
            unless model
              old_model.delete
            end
          end
          save if sync_options[:save]
          NSLog("SYNC: finished sync for #{key} in #{self.class_name_without_kvo}")
          block.call(data, status_code, response) if use_callback
        else
          NSLog("SYNC ERROR: failed sync for #{key} in #{self.class_name_without_kvo}")
          block.call(data, status_code, response) if use_callback
        end
      end
    end

    def fetch_has_one(key, options = {}, &block)
      use_callback = block_given?
      NSLog("SYNC: started sync for #{key} in #{self.class_name_without_kvo}")
      api_client.get normalize_sync_url(options[:sync_url]) do |response, status_code|
        data = options.has_key?(:sync_key) ? response[options[:sync_key]] : response
        if data.present?
          model = self.send(key)
          unless model
            model = key.classify.constantize.new
            self.send(:"#{key}_bag") << model
          end
          model.fetch_with_attributes(data)
          model.save if sync_options[:save]
          block.call(data, status_code, response) if use_callback
        else
          NSLog("SYNC ERROR: failed sync for #{key} in #{self.class_name_without_kvo}")
          block.call(data, status_code, response) if use_callback
        end
      end
    end

    def filtered_updatable_attributes(options = {})
      slice_attributes = options[:updatable_attributes].map(&:to_sym) if options.has_key?(:updatable_attributes)
      updatable_attributes = self.class.updatable_attributes

      if updatable_attributes.blank?
        attrs =  slice_attributes ? attributes_hash.slice(*slice_attributes) : attributes_hash
        return attrs.merge(files: {})
      end

      updatable_attributes = updatable_attributes.slice(*slice_attributes) if slice_attributes
      updatable_attributes.to_a.inject({files: {}}) do |hash, attribute|
        key, options = *attribute
        next hash if options[:if] && !send(options[:if])
        value = if block = options[:block]
          block.call(self, hash)
        else
          info[key]
        end

        if key.to_s.starts_with?('file_')
          value.to_a.each do |file_data|
            file_name, file = file_data.to_a
            hash[:files]["[#{key.partition('_').last}]#{file_name}"] = file
          end
        else
          hash.merge!(key => value)
        end
        hash
      end
    end

    def normalize_sync_url(url)
      url.to_s.gsub(':id', id.to_s)
    end

    module ClassMethods
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
          updatable_attribute attribute
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