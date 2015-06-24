require 'test_helper'

class UserEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit " do
    get edit_user_path(@user)
    patch user_path(@user), user: {name: '', email: 'foo@invalid', password: '', password_confirmation: ''}

    assert_template 'users/edit'
    assert_not flash.empty?
    @user.reload
    assert_redirected_to @user

    assert_equal @user.name, name
    assert_equal @user.name, email
  end

end
