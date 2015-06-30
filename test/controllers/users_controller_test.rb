require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get :new
    assert_response :success
  end


  test 'should get edit' do
    get :edit , id: @user
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch :update, id: @user, user: { name: @user.name, email: @user.email}
    assert_redirected_to login_url
  end

  test 'should redirect edit with logged in as wrong user' do
    log_in_as(@other_user)
    get :edit, id: @user
    assert_redirected_to root_url
  end

  test 'should redirect update with loggin in as wrong user' do
    log_in_as(@other_user)
    get :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_redirected_to root_url
  end

  test 'should redirect index when not logged in' do
    get :index
    assert_redirected_to login_url
  end

  test 'should redirect destory when not login in' do
    assert_no_difference "User.count" do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test 'should redirect destory when login in as no-admin' do
    log_in_as(@other_user)

    assert_no_difference "User.count" do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end

end
