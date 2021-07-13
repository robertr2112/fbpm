# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE)
#  confirmation_token     :string
#  confirmed              :boolean          default(FALSE)
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

  attr_accessor :remember_token

  has_many :pool_memberships, dependent: :destroy
  has_many :pools, through: :pool_memberships, dependent: :destroy
  has_many :entries, dependent: :delete_all

  before_save { email.downcase! }

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

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  def send_user_confirm
    self.update_attribute(:confirmation_token, create_token)
    UserMailer.confirm_registration(self).deliver_now
  end

  def send_password_reset
    self.update_attribute(:password_reset_token, create_token)
    self.update_attribute(:password_reset_sent_at, Time.zone.now)
    UserMailer.password_reset(self).deliver_now
  end

  private

    def create_token
      User.digest(User.new_token)
    end

end
