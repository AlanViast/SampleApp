require 'test_helper'

class UserEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'unsuccessful edit ' do
    log_in_as(@user)
    get edit_user_path(@user)
    patch user_path(@user), user: {name: '', email: 'foo@invalid', password: 'foo', password_confirmation: ''}
    assert_template 'users/edit'
  end


  test "successful edit " do
    log_in_as(@user)
    get edit_user_path(@user)
    name = "Foor bar"
    email = "foo@bar.com"
    patch user_path(@user), user: {name: name, email: email, password: '', password_confirmation: ''}

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end

  test 'successful edit with frirendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name = "For bar"
    email = "foor@bar.com"
    patch user_path(@user), user: { name: name, email: email, password: "foobar", password_confirmation: "foobar"}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end

  test 'should edit user admin' do
    get edit_user_path(@other_user)
    log_in_as(@other_user)
    assert_redirected_to edit_user_path(@other_user)
    name = "Foobar"
    email = "foobar@exmaple.com"
    patch user_path(@other_user), user: { name: name, email: email, password: "foobar", password_confirmation: "foobar", admin: 1}
    assert_not flash.empty?
    assert_redirected_to @other_user
    @other_user.reload
    assert_not @other_user.admin?
  end

end
