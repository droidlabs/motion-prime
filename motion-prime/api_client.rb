class ApiClient
  attr_accessor :access_token

  def initialize(options = {})
    self.access_token = options[:access_token]
  end

  def request_params(data)
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
      block.call(access_token) if use_callback
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

  def request(method, path, params = {}, &block)
    params.merge!(access_token: access_token)
    BW::HTTP.send method, api_url(path), request_params(params) do |response|
      json = parse_json(response.body.to_s)
      block.call(json, response.status_code)
    end
  end

  def get(path, params = {}, &block)
    request(:get, path, params, &block)
  end

  def put(path, params = {}, &block)
    request(:put, path, params, &block)
  end

  def post(path, params = {}, &block)
    request(:post, path, params, &block)
  end

  def delete(path, params = {}, &block)
    request(:delete, path, params, &block)
  end

  private
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