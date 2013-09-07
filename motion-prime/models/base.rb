motion_require '../helpers/has_authorization'
motion_require './bag.rb'
motion_require './finder.rb'
motion_require './model.rb'
motion_require './store.rb'
motion_require './store_extension.rb'
module MotionPrime
  class BaseModel < NSFNanoObject
    class_attribute :_sync_url
    class_attribute :_updatable_attributes
    class_attribute :_associations

    include MotionPrime::HasAuthorization

    include MotionPrime::ModelMethods
    extend MotionPrime::ModelClassMethods

    extend MotionPrime::ModelFinderMethods
    include MotionPrime::ModelAssociationMethods

    extend MotionPrime::ModelAssociationClassMethods

    def errors
      @errors ||= Errors.new(self)
    end

    def sync_url(method = :get)
      url = self.class.sync_url
      if url.is_a?(Proc)
        raise StandardError, "no method given" unless method.present?
        url = url.call(method)
      end
      normalize_sync_url(url)
    end

    def model_name
      self.class.name.underscore
    end

    def new_record?
      id.blank?
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

      method = if should_update
        persisted? ? :put : :post
      else
        :get
      end
      url = sync_url(method)

      if url.blank?
        should_fetch = false
        should_update = false
      end

      should_fetch = !new_record? if should_fetch.nil?
      should_update = new_record? if should_update.nil?

      fetch_with_url url do
        save if sync_options[:save]
        block.call if use_callback
      end if should_fetch

      update_with_url url, sync_options do |data, status_code|
        save if sync_options[:save] && status_code.to_s =~ /20\d/
        # run callback only if it wasn't run on fetch
        block.call(data, status_code) if use_callback && !should_fetch
      end if should_update

      fetch_associations(sync_options) do
        # run callback only if it wasn't run on fetch or update
        block.call if use_callback && !should_fetch && !should_update
      end if should_fetch_associations
    end

    # fetch from server using url
    def fetch_with_url(url, &block)
      api_client.get(url) do |data|
        if data.present?
          fetch_with_attributes(data, &block)
        end
      end
    end

    # update on server using url
    def update_with_url(url, sync_options = nil, &block)
      use_callback = block_given?
      post_data = { model_name => filtered_updatable_attributes(sync_options)}
      api_client.send(id ? :put : :post, url, post_data) do |data, status_code|
        if status_code.to_s =~ /20\d/ && data.is_a?(Hash)
          self.id ||= data['id']
          accessible_attributes = self.class.attributes.map(&:to_sym) - [:id]
          attrs = data.symbolize_keys.slice(*accessible_attributes)
          fetch_with_attributes(attrs)
        end
        block.call(data, status_code) if use_callback
      end
    end

    # set attributes, using fetch
    def fetch_with_attributes(attrs, &block)
      attrs.each do |key, value|
        if respond_to?(:"fetch_#{key}")
          self.send(:"fetch_#{key}", value)
        elsif respond_to?(:"#{key}=")
          self.send(:"#{key}=", value)
        end
      end
      block.call(self) if block_given?
    end

    def fetch_associations(sync_options = {}, &block)
      use_callback = block_given?
      associations = self.class._associations || {}

      associations.keys.each_with_index do |key, index|
        if use_callback && associations.count - 1 == index
          fetch_association(key, sync_options, &block)
        else
          fetch_association(key, sync_options)
        end
      end
    end

    def fetch_association(key, sync_options = {}, &block)
      options = self.class._associations[key]
      return unless options[:sync_url]
      options[:type] == :many ?
      fetch_has_many(key, options, sync_options, &block) :
      fetch_has_one(key, options, sync_options, &block)
    end

    def fetch_has_many(key, options = {}, sync_options = {}, &block)
      old_collection = self.send(key)
      use_callback = block_given?
      puts "SYNC: started sync for #{key} in #{self.class.name}"
      api_client.get normalize_sync_url(options[:sync_url]) do |data|
        data = data[options[:sync_key]] if options[:sync_key]
        if data.present?
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
          puts "SYNC: finished sync for #{key} in #{self.class.name}"
          block.call if use_callback
        else
          puts "SYNC ERROR: failed sync for #{key} in #{self.class.name}"
          block.call if use_callback
        end
      end
    end

    def fetch_has_one(key, options = {}, &block)
      use_callback = block_given?
      puts "SYNC: started sync for #{key} in #{self.class.name}"
      api_client.get normalize_sync_url(options[:sync_url]) do |data|
        data = data[options[:sync_key]] if options[:sync_key]
        if data.present?
          model = self.send(key)
          unless model
            model = key.singularize.to_s.classify.constantize.new
            self.send(:"#{key}_bag") << model
          end
          model.fetch_with_attributes(data)
          model.save if sync_options[:save]
          block.call if use_callback
        else
          puts "SYNC ERROR: failed sync for #{key} in #{self.class.name}"
          block.call if use_callback
        end
      end
    end

    def inspect
      "#<#{self.class}:0x#{self.object_id.to_s(16)}> " + MotionPrime::JSON.generate(info)
    end

    def filtered_updatable_attributes(options = {})
      slice_attributes = options[:updatable_attributes].map(&:to_sym) if options.has_key?(:updatable_attributes)
      updatable_attributes = self.class.updatable_attributes

      if updatable_attributes.blank?
        attrs = attributes_hash.slice(*slice_attributes) if slice_attributes
        return attrs
      end

      updatable_attributes = updatable_attributes.slice(*slice_attributes) if slice_attributes
      updatable_attributes.to_a.inject({}) do |hash, attribute|
        key, options = *attribute
        return hash if options[:if] && !send(options[:if])
        value = if block = options[:block]
          block.call(self)
        else
          info[key]
        end
        hash.merge(key => value)
      end
    end

    def normalize_sync_url(url)
      url.to_s.gsub(':id', id.to_s)
    end

    def attributes_hash
      self.info.to_hash.symbolize_keys
    end

    class << self
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