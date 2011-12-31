require 'heroku'

module Delayed
  module Manager
    class HerokuCedar
      def initialize(options={})
        username = options[:username] || ENV['HEROKU_USERNAME']
        password = options[:password] || ENV['HEROKU_PASSWORD']
        @max_scale = options[:max_workers] || ENV['DJ_MAX_WORKERS'] || 10
        @app     = options[:app]      || ENV['HEROKU_APP']
        @client = ::Heroku::Client.new(username, password)
      end

      def qty
        @client.ps(@app).select {|p| p["process"] =~ /^worker\./ and ["up", "starting"].include? p["state"]}.size
      end

      def scale_up
        @client.ps_scale(@app, :type => "worker", :qty => [self.qty + 1, @max_scale].min)
      end

      def scale_down
        @client.ps_scale(@app, :type => "worker", :qty => [self.qty - 1, 0].max)
      end
    end
  end
end