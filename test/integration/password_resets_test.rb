require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
  	ActionMailer::Base.deliveries.clear
  	@user = users(:michael)
  end


  test ' password resets ' do
  	get new_password_reset_path
  	assert_template 'password_resets/new'

  	post password_resets_path, password_reset: {email: ""}
  	assert_not flash.empty?
  	assert_template 'password_resets/new'

  	# 有效的电子邮箱
  	post password_resets_path, password_reset: { email: @user.email }
  	assert_not_equal @user.reset_digest, @user.reload.reset_digest
  	# 判断是否发出一封邮件
  	assert_equal 1, ActionMailer::Base.deliveries.size
  	assert_not flash.empty?
  	assert_redirected_to root_url

  	user = assigns( :user )
  	# 电子邮箱错误的
  	get edit_password_reset_path( user.reset_token, email: '' )
  	assert_redirected_to root_url

  	# 用户未激活
  	# 切换激活状态
  	user.toggle!( :activated )
  	get edit_password_reset_path( user.reset_token, email: user.email )
  	assert_redirected_to root_url
  	user.toggle!( :activated )

  end

  test 'expired token ' do
    get new_password_reset_path
    post password_resets_path, password_reset: {email: @user.email}

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
      email: @user.email,
      user: {
        password: "foobar",
        password_confirmation: "foobar"
      }
    assert_response :redirect
    follow_redirect!
    assert_match "Password reset has expired.", response.body
  end

end
