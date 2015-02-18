require 'api/warden_strategies/api_token'
require 'api/warden_strategies/password'

class Authentication
  def initialize(app)
    @app = Warden::Manager.new(app) do |config|
      config.default_scope = :api
      config.failure_app = -> _ { [401, { 'Content-Length' => '0' }, ['']] }
      config.scope_defaults(
        :password,
        strategies: [:password],
        store: false,
        action: 'unauthenticated'
      )

      config.scope_defaults(
        :api,
        strategies: [:api_token],
        store: false,
        action: 'unauthenticated'
      )
    end
  end

  def call(env)
    @app.call(env)
  end
end

