# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  activated              :boolean          default(FALSE)
#  activated_at           :datetime
#  activation_digest      :string
#  admin                  :boolean          default(FALSE)
#  contact                :integer          default(1)
#  email                  :string
#  name                   :string
#  password_digest        :string
#  password_reset_sent_at :datetime
#  password_reset_token   :string
#  phone                  :string
#  remember_digest        :string
#  supervisor             :boolean          default(FALSE)
#  user_name              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email            (email) UNIQUE
#  index_users_on_remember_digest  (remember_digest)
#

class User < ApplicationRecord

  attr_accessor :remember_token, :activation_token

  before_save   :downcase_email
  before_create :create_activation_digest

  CONTACT_PREF = { Both: 1, Email: 2, Text: 3 }

  has_many :pool_memberships, dependent: :destroy
  has_many :pools, through: :pool_memberships, dependent: :destroy
  has_many :entries, dependent: :delete_all

  validates :name,  presence: true, length: { :maximum => 50 }
  validates :user_name,  presence: true, length: { :maximum => 15 },
                    uniqueness: { case_sensitive: false }
  validates :phone, phone: { possible: true, allow_blank: true },
                   presence: true, if: :phone_required?
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :contact, inclusion:   { in: 1..3 }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  default_scope -> { order(name: :asc) }

  has_secure_password

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                              BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
#   update_attribute(:activated,    true)
#   update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Resend the activation email
  def resend_activation
    create_activation_digest
    send_activation_email
    save
  end

  def send_password_reset
    self.update_attribute(:password_reset_token, create_token)
    self.update_attribute(:password_reset_sent_at, Time.zone.now)
    UserMailer.password_reset(self).deliver_now
  end

  # !!! Use this until password reset is redone
  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def phone_required?
    if self.contact == User::CONTACT_PREF[:Both] ||
        self.contact == User::CONTACT_PREF[:Text]
      return true
    else
      return false
    end
  end

  private

    def downcase_email
      email.downcase!
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

    def create_token
      User.encrypt(User.new_token)
    end

end
