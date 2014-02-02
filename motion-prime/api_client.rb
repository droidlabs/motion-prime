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
      block.call(auth_data, response.operation.response.statusCode) if use_callback
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
    params.merge!(access_token: access_token)
    data = request_params(params)
    files = data.delete(:_files)
    use_callback = block_given?

    client_method = files.present? ? :"multipart_#{method}" : method
    AFMotion::Client.shared.send client_method, "#{config.api_namespace}#{path}", data do |response, form_data, progress|
      if form_data && files.present?
        files.each do |file_data|
          form_data.appendPartWithFileData(file_data[:data], name: file_data[:name], fileName:"avatar.png", mimeType: "image/jpeg")
        end
      elsif progress
        # handle progress
      elsif !response.success? && options[:allow_queue] && config.allow_queue?
        add_to_queue(method: method, path: path, params: params)
      else
        block.call(prepared_object(response.object), response.operation.response.statusCode) if use_callback
        process_queue
      end
    end
  end

  def process_queue
    queue = user_defaults['api_client_queue']
    user_defaults['api_client_queue'] = []
    Array.wrap(queue).each do |item|
      request(item[:method], item[:path], item[:params].clone.symbolize_keys)
    end
  end

  def add_to_queue(item)
    queue = user_defaults['api_client_queue'].clone || []
    queue.push(item)
    user_defaults['api_client_queue'] = queue
  end

  def get(path, params = {}, options = {}, &block)
    request(:get, path, params, options, &block)
  end

  def put(path, params = {}, options = {}, &block)
    request(:put, path, params, options, &block)
  end

  def post(path, params = {}, options = {}, &block)
    options[:allow_queue] = true unless options.has_key?(:allow_queue)
    request(:post, path, params, options, &block)
  end

  def delete(path, params = {}, options = {}, &block)
    options[:allow_queue] = true unless options.has_key?(:allow_queue)
    request(:delete, path, params, options, &block)
  end

  private

    def config
      MotionPrime::Config.api_client
    end

    def user_defaults
      @user_defaults ||= NSUserDefaults.standardUserDefaults
    end

    def prepared_object(object)
      if object.is_a?(Hash)
        object.with_indifferent_access
      elsif object.is_a?(Array)
        object.map(&:with_indifferent_access)
      else
        object
      end
    end
end