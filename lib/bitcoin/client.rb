require 'net/http'

module Bitcoin
  class Client
    def initialize(options)
      @options = options
    end

    def execute(command, *args)
      request('id' => 'jsonrpc', 'method' => command, 'params' => args)
    end

    private

    def build_endpoint(options)
      host = options[:host] || 'localhost'
      port = options[:port] || '8332'

      auth = options[:user]

      if (pass = options[:password])
        auth = "#{auth}:#{pass}"
      end

      auth = "#{auth}@" if auth

      URI("http://#{auth}#{host}:#{port}")
    end

    def request(params)
      http = Net::HTTP.new(endpoint.host, endpoint.port)

      # SSL:
      #http.use_ssl = true

      request = create_request(params)
      response = http.request(request)
      body = response.body

      JSON.parse(body) unless body.empty?
    end

    def create_request(params)
      request = Net::HTTP::Post.new('/')

      request.body = JSON.generate(params)
      request.basic_auth(endpoint.user, endpoint.password)
      request.content_type = 'application/json'

      request
    end

    def endpoint
      @endpoint ||= build_endpoint(@options)
    end
  end
end

