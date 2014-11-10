module API
  module Entities
    class Secret < Grape::Entity
      expose :id, documentation: { type: 'integer', desc: 'Id of the secret.' }
      expose :title, documentation: { type: 'string', desc: 'Title for the secret.' }
      expose :required, documentation: { type: 'integer', desc: 'Number of shares required to reconstruct this secret.' }
      expose :split, documentation: { type: 'integer', desc: 'Number of chars the secret was split into before applying Shamir\'s Secret Sharing' }
    end

    class User < Grape::Entity
      expose :id, documentation: { type: 'integer', desc: 'The users id.' }
      expose :username, documentation: { type: 'string', desc: 'The users username' }
    end
  end
end
