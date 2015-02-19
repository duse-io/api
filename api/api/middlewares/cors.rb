class Cors
  def initialize(app)
    @app = Rack::Cors.new(app) do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete]
      end
    end
  end

  def call(env)
    @app.call(env)
  end
end

