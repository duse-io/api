module Model
  class Secret
    include DataMapper::Resource

    property :id, Serial
    property :title, String, required: true
    property :required, Integer, required: true
    # max length of a secret part
    property :split, Integer, required: true

    validates_numericality_of :required, gte: 2
    validates_numericality_of :split, gte: 1

    has n, :secret_parts, constraint: :destroy

    def users
      secret_parts.shares.user
    end

    def secret_parts_for(users)
      secret_parts(order: [:index.asc]).map do |part|
        part.raw_shares_from users
      end
    end

    def self.new_full(params)
      secret = Model::Secret.new(
        title: params[:title],
        required: params[:required],
        split: params[:split]
      )
      entities = [secret]

      params[:parts].each_with_index do |part, index|
        secret_part = Model::SecretPart.new(index: index, secret: secret)

        part.each do |user_id, share|
          user = Model::User.get(user_id)
          entities << Model::Share.new(
            user: user,
            secret_part: secret_part,
            content: share
          )
        end

        entities << secret_part
      end

      entities
    end
  end
end
