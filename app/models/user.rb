class User < ApplicationRecord
    before_save { self.email = email.downcase }

    validates :username, presence: true, length: { maximum: 25 },
                        uniqueness: { case_sensitive: false }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: true

    has_secure_password
    VALID_PASSWORD_REGEX = /\A^(?=\S*?[a-z])(?=\S*?[A-Z])(?=\S*?\d)(?=\S*?[\W_])/
    validates :password, presence: true, length: { minimum: 8 }, 
                        format: { with: VALID_PASSWORD_REGEX, message: "must include at least one lowercase letter, one uppercase letter, one digit, and one special character"},
                        allow_nil: true

    enum role: [:regular, :user_manager, :admin]
    before_validation :set_default_role, on: :create
    validates :role, presence: true, inclusion: { in: roles.keys }

    has_many :time_entries, dependent: :destroy

    # Returns true if the given token matches the digest.
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end
    
    # Returns the hash digest of the given string.
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def self.new_token
        SecureRandom.urlsafe_base64
    end

    # Sets the default role to regular, if not already set.
    def set_default_role
        self.role ||= :regular
    end
end
