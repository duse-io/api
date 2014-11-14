module API
  module APIHelpers
    # error helpers

    def forbidden!
      render_api_error!('403 Forbidden', 403)
    end

    def bad_request!(attribute)
      message = ['400 (Bad request)']
      message << "\"" + attribute.to_s + "\" not given"
      render_api_error!(message.join(' '), 400)
    end

    def not_found!(resource = nil)
      message = ['404']
      message << resource if resource
      message << 'Not Found'
      render_api_error!(message.join(' '), 404)
    end

    def unauthorized!
      render_api_error!('401 Unauthorized', 401)
    end

    def not_allowed!
      render_api_error!('405 Method Not Allowed', 405)
    end

    def conflict!(message = nil)
      render_api_error!(message || '409 Conflict', 409)
    end

    def render_api_error!(message, status)
      error!({ message: message }, status)
    end

    def aggregate_secret_errors(accumulator, entities)
      entities.each do |entity|
        accumulator = accumulator.merge entity.errors.full_messages unless entity.valid?
      end

      accumulator.subtract ['Secret must not be blank', 'Secret part must not be blank']
    end

    # params extraction & validation

    def extract_params(keys)
      attrs = {}

      keys.each do |key|
        attrs[key] = extract_param key
      end

      attrs
    end

    def extract_param(key)
      params[key]
    end

    # user & authentication

    def current_user
      env['warden'].user
    end

    def authenticate!(scope = :api_token)
      env['warden'].authenticate!(scope)
    end
  end
end
