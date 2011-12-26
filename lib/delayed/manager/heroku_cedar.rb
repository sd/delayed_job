require 'heroku'

module Delayed
  module Manager
    class Heroku
      def initialize(options={})
        username = options[:username] || ENV['HEROKU_USERNAME']
        password = options[:password] || ENV['HEROKU_PASSWORD']
        @app     = options[:app]      || ENV['HEROKU_APP']
        @client = ::Heroku::Client.new(username, password)
      end

      def max_scale
        options[:max_scale] || ENV['DJ_MAX'] || 10
      end
      
      def qty
        @client.ps(@app).select {|p| p["process"] =~ /^worker\./ and p["state"] == "up"}.size
      end

      def scale_up
        @client.ps_scale(@app, :type => worker, :qty => [self.qty + 1, max_scale].min)
      end

      def scale_down
        @client.ps_scale(@app, :type => worker, :qty => [self.qty - 1, 0].ax)
      end
    end
  end
end