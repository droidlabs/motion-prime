motion_require '../helpers/has_authorization'
motion_require './bag.rb'
motion_require './finder.rb'
motion_require './model.rb'
motion_require './store.rb'
motion_require './store_extension.rb'
module MotionPrime
  class BaseModel < NSFNanoObject
    class_attribute :sync_url
    class_attribute :_updatable_attributes
    class_attribute :_associations
    alias_method :attributes, :info
    include MotionPrime::HasAuthorization

    include MotionPrime::ModelMethods
    extend MotionPrime::ModelClassMethods

    extend MotionPrime::ModelFinderMethods
    include MotionPrime::ModelAssociationMethods

    extend MotionPrime::ModelAssociationClassMethods

    def sync_url
      self.class.sync_url.to_s.gsub(':id', id.to_s)
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
      api_client.delete(sync_url) do
        block.call() if use_callback
      end
      delete
    end

    # sync with server and save on local
    def sync!(sync_options = {}, &block)
      sync(sync_options.merge(save: true), &block)
    end

    # sync with with server
    # TODO: order of fetch/update should be based on updated time
    def sync(sync_options = {}, &block)
      use_callback = block_given?
      should_fetch = sync_options[:fetch]
      should_update = sync_options[:update]

      should_fetch = !new_record? if should_fetch.nil?
      should_update = new_record? if should_update.nil?

      fetch_with_url self.sync_url do
        save if sync_options[:save]
        block.call if use_callback
      end if should_fetch
      update_with_url self.sync_url do
        save if sync_options[:save]
        block.call if use_callback
      end if should_update

      fetch_associations(sync_options)
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
    def update_with_url(url, &block)
      use_callback = block_given?
      post_data = { model_name => filtered_updatable_attributes}
      api_client.send(id ? :put : :post, url, post_data) do |data|
        self.id ||= data['id']
        block.call() if use_callback
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

    def fetch_associations(sync_options = {})
      (self.class._associations || []).each do |key, options|
        fetch_association(key, sync_options)
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
      api_client.get(options[:sync_url]) do |data|
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
      # TODO: add implementation
    end

    def inspect
      "#<#{self.class}:0x#{self.object_id.to_s(16)}> " + MotionPrime::JSON.generate(attributes)
    end

    def filtered_updatable_attributes
      return attributes if self.class.updatable_attributes.blank?
      self.class.updatable_attributes.to_a.inject({}) do |hash, attribute|
        key, options = *attribute
        if block = options[:block]
          value = instance_eval(&block)
        else
          value = attributes[key]
        end
        hash.merge!(key => value)
      end
    end

    class << self
      def sync_url(url = nil)
        url ? self.sync_url = url : super
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