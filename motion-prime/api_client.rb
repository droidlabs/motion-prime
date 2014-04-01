class ApiClient
  attr_accessor :access_token

  def initialize(options = {})
    self.access_token = options[:access_token]
    AFMotion::Client.build_shared(config.base) do
      header "Accept", "application/json"
      response_serializer AFJSONResponseSerializer.serializerWithReadingOptions(NSJSONReadingMutableContainers)
    end
  end

  def request_params(data)
    params = data.clone

    if config.http_auth?
      params.merge!(credentials: config.http_auth.to_hash)
    end
    if config.sign_request?
      signature = RmDigest::MD5.hexdigest(
        config.signature_secret + params.keys.map(&:to_s).sort.join
      )
      params.merge!(sign: signature)
    end
    params
  end

  def authenticate(username = nil, password = nil, data = nil, &block)
    data ||= {
      grant_type: "password",
      username: username,
      password: password,
      client_id: config.client_id,
      client_secret: config.client_secret
    }
    use_callback = block_given?
    AFMotion::Client.shared.post(config.auth_path, request_params(data)) do |response|
      auth_data = response.object

      self.access_token = auth_data[:access_token] if auth_data
      block.call(auth_data, response.operation.response.try(:statusCode)) if use_callback
    end
    true
  end

  def page_url(path)
    "#{config.base}#{path}"
  end

  def resource_url(path)
    # return if path.blank?
    base = config.resource_base? ? config.resource_base : config.base
    "#{base}#{path}"
  end

  def request(method, path, params = {}, options = {}, &block)
    files = params.delete(:_files)
    data = request_params(params.merge(access_token: access_token))

    if !options.has_key?(:allow_queue) && config.default_methods_queue.include?(method.to_sym)
      options[:allow_queue] = true
    end

    if !options.has_key?(:allow_cache) && config.default_methods_cache.include?(method.to_sym)
      options[:allow_cache] = true
    end

    if allow_cache?(method, path, options)
      cached_request!(method, path, data, files, options, &block)
    else
      request!(method, path, data, files, options, &block)
    end
  end

  def request!(method, path, data, files = nil, options = {}, &block)
    use_callback = block_given?
    path = "#{config.api_namespace}#{path}" unless path.starts_with?('http')
    client_method = files.present? ? :"multipart_#{method}" : method
    AFMotion::Client.shared.send client_method, path, data do |response, form_data, progress|
      if form_data && files.present?
        append_files_to_data(files, form_data)
      elsif progress
        # handle progress
      elsif !response.success? && allow_queue?(method, path, options)
        queue(method: method, path: path, params: params)
      elsif response.operation.response.nil?
        block.call if use_callback
      else
        prepared_response = prepare_response_object(response.object)
        block.call(prepared_response, response.operation.response.statusCode) if use_callback
        process_queue if config.allow_queue?
      end
    end
  end

  def cached_request!(method, path, data, files = nil, options = {}, &block)
    use_callback = block_given?
    params = data.map { |key, value| "#{key}=#{value}" }.join('&')
    cache_key = [method, path, params].join(' ')
    response = read_cache(cache_key)
    if response && use_callback
      block.call(prepare_response_object(response), 200)
    else
      request!(method, path, data, files, options) do |response, status|
        write_cache(cache_key, response)
        block.call(response, status) if use_callback
      end
    end
  end

  def get(path, params = {}, options = {}, &block)
    request(:get, path, params, options, &block)
  end

  def put(path, params = {}, options = {}, &block)
    request(:put, path, params, options, &block)
  end

  def post(path, params = {}, options = {}, &block)
    request(:post, path, params, options, &block)
  end

  def delete(path, params = {}, options = {}, &block)
    request(:delete, path, params, options, &block)
  end

  def queue(item)
    queue_list = user_defaults['api_client_queue'].clone || []
    queue_list.push(item)
    user_defaults['api_client_queue'] = queue_list
  end

  # TODO: temporary solution, add real caching system here
  def read_cache(key)
    puts "read cache #{key}"
    @cache ||= {}
    @cache[key]
  end

  # TODO: temporary solution, add real caching system here
  def write_cache(key, data)
    @cache ||= {}
    @cache[key] = data
  end

  protected
    def allow_queue?(method, path, options)
      options[:allow_queue] && config.allow_queue?
    end

    def allow_cache?(method, path, options)
      options[:allow_cache] && config.allow_cache?
    end

    def process_queue
      queue_list = user_defaults['api_client_queue']
      user_defaults['api_client_queue'] = []
      Array.wrap(queue_list).each do |item|
        request(item[:method], item[:path], item[:params].clone.symbolize_keys)
      end
    end

    def config
      MotionPrime::Config.api_client
    end

    def user_defaults
      @user_defaults ||= NSUserDefaults.standardUserDefaults
    end

    def append_files_to_data(files, data)
      files.each do |file|
        name = file[:name]
        file_name = file[:file_name] || "avatar.png"
        mime_type = file[:mime_type] || "image/jpeg"
        data.appendPartWithFileData(
          file[:data], name: name, fileName: file_name, mimeType: mime_type
        )
      end
      data
    end

    def prepare_response_object(object)
      if object.is_a?(Hash)
        object.with_indifferent_access
      elsif object.is_a?(Array)
        object.map{ |obj| prepare_response_object(obj) }
      else
        object
      end
    end
end