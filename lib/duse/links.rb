require 'uri'

module Duse
  module Links
    module_function

    def base_url
      Duse.config.protocol + '://' + Duse.config.host
    end

    def build_url(target)
      URI::join(base_url, target)
    end

    def confirmation_link(confirmation_token)
      build_url("/v1/users/confirm?token=#{URI::encode(confirmation_token)}")
    end
  end
end

