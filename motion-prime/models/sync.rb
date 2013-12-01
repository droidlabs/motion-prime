module MotionPrime
  module ModelSyncMethods
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

    # sync with server and save on local
    def sync!(sync_options = {}, &block)
      sync(sync_options.merge(save: true), &block)
    end

    # sync with with server
    # TODO: order of fetch/update should be based on updated time?
    def sync(sync_options = {}, &block)
      use_callback = block_given?
      should_fetch = sync_options[:fetch]
      should_update = sync_options[:update]
      should_fetch_associations = if sync_options.has_key?(:fetch_associations)
        sync_options[:fetch_associations]
      else # do not need to fetch unless this is a GET request
        should_fetch
      end

      method = sync_options[:method]
      method ||= if should_update
        persisted? ? :put : :post
      else
        :get
      end
      url = sync_url(method, sync_options)

      if url.blank?
        should_fetch = false
        should_update = false
      end

      should_fetch = !new_record? if should_fetch.nil?
      should_update ||= new_record? unless should_fetch

      fetch_with_url url do |data, status_code|
        save if sync_options[:save]
        block.call(data, status_code) if use_callback
      end if should_fetch

      update_with_url url, sync_options do |data, status_code|
        save if sync_options[:save] && status_code.to_s =~ /20\d/
        # run callback only if it wasn't run on fetch
        block.call(data, status_code) if use_callback && !should_fetch
      end if should_update

      fetch_associations(sync_options) do |data, status_code|
        # run callback only if it wasn't run on fetch or update
        block.call(data, status_code) if use_callback && !should_fetch && !should_update
      end if should_fetch_associations
    end

    # fetch from server using url
    def fetch_with_url(url, &block)
      use_callback = block_given?
      api_client.get(url) do |data, status_code|
        fetch_with_attributes(data, &block) if data.present?
        block.call(data, status_code) if use_callback
      end
    end

    # update on server using url
    def update_with_url(url, sync_options = nil, &block)
      use_callback = block_given?
      filtered_attributes = filtered_updatable_attributes(sync_options)

      post_data = sync_options[:params_root] || {}
      post_data[:files] = {}
      filtered_attributes.delete(:files).each do |file_name, file|
        post_data[:files][[model_name, file_name].join] = file
      end
      post_data[model_name] = filtered_attributes

      method = sync_options[:method] || (id ? :put : :post)
      api_client.send(method, url, post_data) do |data, status_code|
        update_from_response = sync_options.has_key?(:update_from_response) ? sync_options[:update_from_response] : true
        if update_from_response && status_code.to_s =~ /20\d/ && data.is_a?(Hash)
          set_attributes_from_response(data)
        end
        block.call(data, status_code) if use_callback
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
      puts "SYNC: started sync for #{key} in #{self.class_name_without_kvo}"
      api_client.get normalize_sync_url(options[:sync_url]) do |response, status_code|
        data = options.has_key?(:sync_key) ? response[options[:sync_key]] : response
        if data
          # Update/Create existing records
          data.each do |attributes|
            model = old_collection.detect{ |model| model.id == attributes[:id]}
            unless model
              model = key.singularize.to_s.classify.constantize.new
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
          puts "SYNC: finished sync for #{key} in #{self.class_name_without_kvo}"
          block.call(data, status_code, response) if use_callback
        else
          puts "SYNC ERROR: failed sync for #{key} in #{self.class_name_without_kvo}"
          block.call(data, status_code, response) if use_callback
        end
      end
    end

    def fetch_has_one(key, options = {}, &block)
      use_callback = block_given?
      puts "SYNC: started sync for #{key} in #{self.class_name_without_kvo}"
      api_client.get normalize_sync_url(options[:sync_url]) do |response, status_code|
        data = options.has_key?(:sync_key) ? response[options[:sync_key]] : response
        if data.present?
          model = self.send(key)
          unless model
            model = key.singularize.to_s.classify.constantize.new
            self.send(:"#{key}_bag") << model
          end
          model.fetch_with_attributes(data)
          model.save if sync_options[:save]
          block.call(data, status_code, response) if use_callback
        else
          puts "SYNC ERROR: failed sync for #{key} in #{self.class_name_without_kvo}"
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
  end

  module ModelSyncClassMethods
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