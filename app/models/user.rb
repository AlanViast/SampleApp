class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,  length: { maximum: 255},
                                                            format: { with: VALID_EMAIL_REGEX },
                                                            uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, allow_blank: true
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

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    return false if self.remember_digest.nil?
    update_attribute(:remember_digest, nil)
  end

  def activate
    self.update_attribute(:activated , true)
    self.update_attribute(:activated_at , Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation( self ).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    self.update_attribute(:reset_digest, User.digest(self.reset_token))
    self.update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
   self.reset_sent_at < 3.minute.ago
  end

  private
    def downcase_email
      self.email.downcase!
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest( self.activation_token )
    end
end
