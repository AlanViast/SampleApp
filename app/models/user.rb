class User < ActiveRecord::Base
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,  length: { maximum: 255},
                                                            format: { with: VALID_EMAIL_REGEX },
                                                            uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  has_secure_password # use secure password

  class << self
    # 返回指定的哈系数据摘要
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      return BCrypt::Password.create(string, cost: cost)
    end

    # 创建一个随机令牌
    def new_token
      return SecureRandom.urlsafe_base64
    end
  end

  # 为了持久会话,  在数据库中记住用户
  def remember
    self.remember_token = User.new_token
    return update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    return false if self.remember_digest.nil?
    update_attribute(:remember_digest, nil)
  end
end
