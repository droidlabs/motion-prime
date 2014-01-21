class ApiClient
  attr_accessor :access_token

  def initialize(options = {})
    self.access_token = options[:access_token]
  end

  def request_params(data)
    data = data.clone
    files = data.delete(:files)
    params = {
      payload: data,
      no_redirect: !config.allow_redirect,
      format: config.request_format
    }
    if files.present?
      params.merge!(files: files)
    end
    if config.http_auth?
      params.merge!(credentials: config.http_auth.to_hash)
    end
    if config.sign_request?
      signature = RmDigest::MD5.hexdigest(
        config.signature_secret + data.keys.map(&:to_s).sort.join
      )
      params[:payload].merge!(sign: signature)
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
    BW::HTTP.post("#{config.base}#{config.auth_path}", request_params(data)) do |response|
      access_token = if response.ok?
        json = parse_json(response.body)
        json[:access_token]
      else
        false
      end
      self.access_token = access_token
      json = parse_json(response.body.to_s)
      block.call(access_token, json, response.status_code) if use_callback
    end
    true
  end

  def api_url(path)
    return path if path =~ /^http(s)?:\/\//
    "#{config.base}#{config.api_namespace}#{path}"
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
    use_callback = block_given?
    BW::HTTP.send method, api_url(path), request_params(params) do |response|
      if !response.ok? && options[:allow_queue]
        add_to_queue(method: method, path: path, params: params)
      else
        json = parse_json(response.body.to_s)
        block.call(json, response.status_code) if use_callback
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
    def user_defaults
      @user_defaults ||= NSUserDefaults.standardUserDefaults
    end

    def parse_json(text)
      Prime::JSON.parse(text)
    rescue
      NSLog("Can't parse json: #{text}")
      false
    end

    def config
      MotionPrime::Config.api_client
    end
end