require 'spec_helper'

describe User do

	before(:each) do
		@attr = { :name => "Example User",
		       	  :email => "user@example.com" ,
			  :password => "foobar",
			  :password_confirmation => "foobar" }
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


	describe "password validations" do

	before(:each) do
		@user = User.create!(@attr)
	end

	it "should have encrypted_password attribute" do
		@user.should respond_to(:encrypted_password)
	end


	it "should require a password" do
		User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
	end

	it "should require matching password and password confirmation" do

		User.new(@attr.merge(:password_confirmation => "invalid")).should_not be_valid

	end

	it "should reject short password" do
		short = "a" * 5
		hash = @attr.merge(:password => short, :password_confirmation => short)
		User.new(hash).should_not be_valid
	end

	it "should reject long password" do
		long = "a" * 41
		hash = @attr.merge(:password => long, :password_confirmation => long)
		User.new(hash).should_not be_valid
	end

	it "should have non blank encrypted_password" do
		@user.encrypted_password.should_not be_blank
	end

	describe "has_password? method examples" do
	
		it "should be true for matching passwords" do
			@user.has_password?(@attr[:password]).should be_true
		end

		it "should be false for different passwords" do
			@user.has_password?("invalid").should be_false
		end

	end

	describe "authenticate method" do

		it "should return nil on email/password mismatch" do
			wrong_password_user = User.authenticate(@attr[:email], "wrongpassword")
			wrong_password_user.should be_nil
		end

		it "should return nil for an email address with no user" do
			nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
			nonexistent_user.should be_nil
		end

		it "should return the user on email/password match" do
			matching_user = User.authenticate(@attr[:email], @attr[:password])
			matching_user.should == @user
		end
	end
	

	end

	describe "admin attribute" do

		before(:each) do
			@user = User.create!(@attr)
		end

		it "should respond to admin" do
			@user.should respond_to(:admin)
		end

		it "should not be admin by default" do
			@user.should_not be_admin
		end

		it "should be convertible to an admin" do
			@user.toggle!(:admin)
			@user.should be_admin
		end

	end
	describe "microposts associations" do
		before(:each) do
			@user = User.create(@attr)
			@mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
			@mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
		end
		it "should have microposts attribute" do
			@user.should respond_to(:microposts)
		end
		it "should have microposts in the right order" do
			@user.microposts.should == [@mp2, @mp1]
		end
		it "should destroy associated microposts" do
			@user.destroy
			[@mp1,@mp2].each do |micropost|
				Micropost.find_by_id(micropost.id).should be_nil
			end
		end

		describe "status feed" do
			it "should have a feed" do
				@user.should respond_to(:feed)
			end
			it "should include the user's microposts" do
				@user.feed.include?(@mp1).should be_true
				@user.feed.include?(@mp2).should be_true
			end
			it "should not include a different user's microposts" do
				mp3 = Factory(:micropost, :user => Factory(:user, :email => Factory.next(:email)))
				@user.feed.include?(mp3).should be_false
			end
		end
	end
end
