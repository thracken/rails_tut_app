require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Sample User", email: "user@example.com", password: "foobar12", password_confirmation: "foobar12")
  end

  test "Should be valid" do
    assert @user.valid?
  end

  test "Name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "Email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "Name shouldn't be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "Email shouldn't be too long" do
    @user.name = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation accepts a valid address" do
    valid_emails = ["user@example.com", "USER@foo.COM", "A_US-ER@foo.bar.org", "first.last@foo.jp", "alice+bob@baz.cn"]
    valid_emails.each do |address|
      @user.email = address
      assert @user.valid?, "#{address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_emails = ["user@example,com", "user_at_foo.org", "user.name@example.", "foo@bar_baz.com", "foo@bar+baz.com"]
    invalid_emails.each do |address|
      @user.email = address
      assert_not @user.valid? "#{address.inspect} should be invalid"
    end
  end

  test "email is unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present and not blank" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = " " * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with a nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end
end
