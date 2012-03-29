require 'spec_helper'

describe User do

	before(:each) do
		@attr = { :name => "Example User", :email => "user@example.com" }
	end

	it "should create a new instance given valid attributes" do
		User.create!(@attr)
	end

	it "should require a name" do
		no_name_user = User.new(@attr.merge(:name => ""))
		no_name_user.should_not be_valid
	end

	it "should require an email" do
		no_name_user = User.new(@attr.merge(:email => ""))
		no_name_user.should_not be_valid
	end

	it "should require name to be 50 chars max" do
		fifty_one = 'a' * 51
		too_long_name_user = User.new(@attr.merge(:name => fifty_one))
		too_long_name_user.should_not be_valid
	end

	it "should accept valid emails" do
		addresses = %w[user@domain.com user.USER@domeain.com user@domain.jp]
		addresses.each do |address|
			valid_email_user = User.new(@attr.merge(:email => address))
			valid_email_user.should be_valid
		end
	end

	it "should reject invalid emails" do
		addresses = %w[userdomain.com useruser@domeain,com userdomain.jp]
		addresses.each do |address|
			invalid_email_user = User.new(@attr.merge(:email => address))
			invalid_email_user.should_not be_valid
		end
	end

	it "should not allow duplicate emails" do
		# create another email as the 'before each'
		User.create!(@attr)
		user_same_email = User.new(@attr)
		user_same_email.should_not be_valid
	end

	it "should not allow duplicate emails different casing" do
		# create another email as the 'before each'
		User.create!(@attr)
		user_same_email = User.new(@attr.merge(:email => @attr[:email].upcase))
		user_same_email.should_not be_valid
	end
end
