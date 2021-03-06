class UsersController < ApplicationController
  before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge, :edit]
  before_filter :find_user, :only => [:update, :show, :edit, :suspend, :unsuspend, :destroy, :purge]
  
  skip_before_filter :login_required, :only => [:new,:create,:activate]
  
  # Brainbuster Captcha
  # before_filter :create_brain_buster, :only => [:new]
  # before_filter :validate_brain_buster, :only => [:create]

  def index
    users_scope = admin? ? :all_users : :users
    if params[:q]
      @users = current_site.send(users_scope).named_like(params[:q]).paginate(:page => current_page)
    else
      @users = current_site.send(users_scope).paginate(:page => current_page)
    end
  end

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    @user = current_site.users.build(params[:user])
    @user.save if @user.valid?
    @user.register! if @user.valid?
    unless @user.new_record?
      redirect_back_or_default('/login')
      flash[:notice] = I18n.t 'txt.activation_required', 
        :default => "Thanks for signing up! Please click the link in your email to activate your account"
    else
      render :action => 'new'
    end
  end

  def settings
    @user = current_user
    current_site
    render :action => "edit"
  end
  
  def edit
    @user = find_user
  end

  def update
    @user = admin? ? find_user : current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = t('txt.user_updated')
        format.html { redirect_to(settings_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def activate
    # not sure why this was using a symbol. Let's use the real false.
    self.current_user = params[:activation_code].blank? ? false : current_site.all_users.find_in_state(:first, :pending, :conditions => {:activation_code => params[:activation_code]})
    if logged_in?
      current_user.activate!
      flash[:notice] = t('txt.user_activated')
    end
    redirect_back_or_default('/')
  end

  def suspend
    @user.suspend!
    flash[:notice] = t('txt.user_suspended')
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend!
    flash[:notice] = t('txt.user_unsuspended')
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  def make_admin
    redirect_back_or_default('/') and return unless admin?
    @user = find_user
    @user.admin = (params[:user][:admin] == "1")
    @user.save
    redirect_to @user
  end

protected
  def find_user
    @user = if admin?
      current_site.all_users.find params[:id]
    elsif params[:id] == current_user.id
      current_user
    else
      current_site.users.find params[:id]
    end or raise ActiveRecord::RecordNotFound
  end

  def authorized?
    current_user ? admin? || params[:id] == current_user.id.to_s || current_user : false
    # current_user ? admin? || params[:id] == current_user.id.to_s : false
  end

  def render_or_redirect_for_captcha_failure
    render :action => 'new'
  end
end