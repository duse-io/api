module API
  module Entities
    class Secret < Grape::Entity
      expose :title, documentation: { type: 'string', desc: 'Title for the secret.' }
      expose :required, documentation: { type: 'integer', desc: 'Number of shares required to reconstruct this secret.' }
      expose :split, documentation: { type: 'integer', desc: 'Number of chars the secret was split into before applying Shamir\'s Secret Sharing' }
    end
  end
end
