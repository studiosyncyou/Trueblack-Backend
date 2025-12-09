require 'httparty'
require 'openssl'
require 'securerandom'

class RistaApiService
  include HTTParty

  base_uri ENV.fetch('RISTA_API_BASE_URL', 'https://api.rista.store/api/v1')

  def initialize
    @api_key = ENV['RISTA_API_KEY']
    @secret = ENV['RISTA_SECRET']
    @timeout = 15

    validate_config!
  end

  # Fetch catalog from Rista
  def fetch_catalog(branch_code, channel = 'Dine In')
    get('/catalog', {
      branch: branch_code,
      channel: channel
    })
  end

  # Create order in Rista POS
  def create_sale(sale_data)
    post('/sale', sale_data)
  end

  # Fetch branches
  def fetch_branches
    get('/branch/list')
  end

  private

  def get(path, query_params = {})
    url = "#{self.class.base_uri}#{path}"
    headers = generate_headers(false)

    Rails.logger.info "[Rista] GET #{url}"
    Rails.logger.debug "[Rista] Query: #{query_params.inspect}"

    response = HTTParty.get(
      url,
      query: query_params,
      headers: headers,
      timeout: @timeout
    )

    handle_response(response, path)
  end

  def post(path, body = {})
    url = "#{self.class.base_uri}#{path}"
    headers = generate_headers(true) # include jti for POST

    Rails.logger.info "[Rista] POST #{url}"
    Rails.logger.debug "[Rista] Body: #{body.to_json}"

    response = HTTParty.post(
      url,
      body: body.to_json,
      headers: headers,
      timeout: @timeout
    )

    handle_response(response, path)
  end

  def generate_headers(include_jti = false)
    timestamp = Time.now.to_i.to_s
    jti = include_jti ? SecureRandom.uuid : nil

    # Generate signature: HMAC-SHA256 of concatenated values
    string_to_sign = [@api_key, timestamp, jti].compact.join
    signature = OpenSSL::HMAC.hexdigest('SHA256', @secret, string_to_sign)

    headers = {
      'Content-Type' => 'application/json',
      'x-api-key' => @api_key,
      'x-signature' => signature,
      'x-timestamp' => timestamp
    }

    headers['x-jti'] = jti if include_jti

    headers
  end

  def handle_response(response, path)
    case response.code
    when 200..299
      Rails.logger.info "[Rista] #{path} - Success (#{response.code})"
      response.parsed_response
    when 400..499
      error_message = response.parsed_response['error'] || response.parsed_response['message'] || 'Client error'
      Rails.logger.error "[Rista] #{path} - Client Error (#{response.code}): #{error_message}"
      raise RistaApiError.new("Rista API error: #{error_message}", response.code)
    when 500..599
      error_message = response.parsed_response['error'] || 'Server error'
      Rails.logger.error "[Rista] #{path} - Server Error (#{response.code}): #{error_message}"
      raise RistaApiError.new("Rista server error: #{error_message}", response.code)
    else
      Rails.logger.error "[Rista] #{path} - Unexpected response code: #{response.code}"
      raise RistaApiError.new("Unexpected response code: #{response.code}", response.code)
    end
  rescue HTTParty::Error, Timeout::Error => e
    Rails.logger.error "[Rista] #{path} - Network error: #{e.message}"
    raise RistaApiError.new("Network error: #{e.message}", nil)
  end

  def validate_config!
    unless @api_key.present? && @secret.present?
      raise ConfigurationError, 'RISTA_API_KEY and RISTA_SECRET must be set'
    end
  end

  # Custom error classes
  class RistaApiError < StandardError
    attr_reader :status_code

    def initialize(message, status_code)
      super(message)
      @status_code = status_code
    end
  end

  class ConfigurationError < StandardError; end
end
