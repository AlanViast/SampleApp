require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Alan", email: "AlanViast@gmail.com", password: "p@ssw0rd", password_confirmation: "p@ssw0rd")
  end

  test "should be valid"  do
    assert @user.valid?
  end

  test 'name should be present ' do
    @user.name = "        "
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = " "
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = "a" * 256
    assert_not @user.valid?
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'email address should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email  = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lower-case' do
    mixed_case_method = "Test@qQ.com"
    @user.email = mixed_case_method
    @user.save
    assert_equal mixed_case_method.downcase, @user.reload.email
  end

  test 'password should hava a minimum length' do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

end
