# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  activated              :boolean          default(FALSE)
#  activated_at           :datetime
#  activation_digest      :string
#  admin                  :boolean          default(FALSE)
#  email                  :string
#  name                   :string
#  password_digest        :string
#  password_reset_sent_at :datetime
#  password_reset_token   :string
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

  has_many :pool_memberships, dependent: :destroy
  has_many :pools, through: :pool_memberships, dependent: :destroy
  has_many :entries, dependent: :delete_all

  validates :name,  presence: true, length: { :maximum => 50 }
  validates :user_name,  presence: true, length: { :maximum => 15 },
                    uniqueness: { case_sensitive: false }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
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

  private

    def downcase_email
      email.downcase!
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
