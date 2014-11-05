module API
  module Entities
    class Share < Grape::Entity
      def self.entity_name
        'share'
      end

      expose :content, documentation: { type: 'string', desc: 'Share from Shamir\'s Secret Sharing to reconstruct a SecretPart'}
    end

    class SecretPart < Grape::Entity
      def self.entity_name
        'secret_part'
      end

      expose :shares, using: Share, documentation: { type: 'share', is_array: true }
    end

    class Secret < Grape::Entity
      expose :title, documentation: { type: 'string', desc: 'Title for the secret.' }
      expose :required, documentation: { type: 'integer', desc: 'Number of shares required to reconstruct this secret.' }
      expose :split, documentation: { type: 'integer', desc: 'Number of chars the secret was split into before applying Shamir\'s Secret Sharing' }
      expose :secret_parts, using: SecretPart, documentation: { type: 'secret_part', is_array: true }
    end
  end
end
