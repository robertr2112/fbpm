# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  activated       :boolean          default(FALSE)
#  activated_at    :datetime
#  admin           :boolean          default(FALSE)
#  contact         :integer          default(1)
#  email           :string
#  name            :string
#  password_digest :string
#  phone           :string
#  supervisor      :boolean          default(FALSE)
#  user_name       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  has_secure_password

  # Handle the email_address_verification
  include EmailAddressVerification
  has_email_address_verification

  has_many :sessions, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }
  default_scope -> { order(name: :asc) }

  CONTACT_PREF = { Email: 1, Both: 2, Text: 3 }

  # Setup pool relationships
  has_many :pool_memberships, dependent: :destroy
  has_many :pools, through: :pool_memberships, dependent: :destroy
  has_many :entries, dependent: :delete_all

  validates :name,  presence: true, length: { maximum: 50 }
  validates :user_name,  presence: true, length: { maximum: 15 },
                    uniqueness: { case_sensitive: false }
  validates :phone, phone: { possible: true, allow_blank: true },
                    presence: true, if: :phone_required?
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true,
                    format: { with: VALID_EMAIL_REGEX }
  # format: { with: URI::MailTo::EMAIL_REGEXP } - This should work but doesn't

  validates :contact, inclusion:   { in: 1..3 }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password, length: { minimum: 6 }, allow_nil: true, on: :update

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                              BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def email_authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Resend the activation email
  def resend_activation
    create_activation_digest
    send_activation_email
    save
  end

  def phone_required?
    if self.contact == User::CONTACT_PREF[:Both] ||
        self.contact == User::CONTACT_PREF[:Text]
      true
    else
      false
    end
  end

  private

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
