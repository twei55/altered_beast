class PasswordsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :login_required, :except => [:create]

  # Don't write passwords as plain text to the log files
  filter_parameter_logging :old_password, :password, :password_confirmation

  # GETs should be safe
  verify :method => :post, :only => [:create], :redirect_to => { :controller => :site }
  # verify :method => :put, :only => [:update], :redirect_to => { :controller => :site }

  # POST /passwords
  # Forgot password
  def create
    respond_to do |format|

      if user = User.find_by_email_and_login(params[:email], params[:login])
        @new_password = random_password
        @email = params[:email]
        user.password = user.password_confirmation = @new_password
        user.save_without_validation
        UserMailer.deliver_new_password(user, @new_password)

        format.html { render :template => "passwords/create" }
      else
        # flash[:notice] =  "We can't find that account.  Try again."
        format.html { render :action => "not_found" }
      end
    end
  end

  protected

  def random_password( len = 8 )
    chars = (("a".."z").to_a + ("1".."9").to_a )- %w(i o 0 1 l 0)
    newpass = Array.new(len, '').collect{chars[rand(chars.size)]}.join
  end

end
