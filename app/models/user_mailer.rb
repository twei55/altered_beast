class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += ' Aktivierung Ihres Benutzerkontos'
    @body[:url]  = activate_url(user.activation_code, :host => user.site.host)
  end
  
  def activation(user)
    setup_email(user)
    @subject    += ' Ihr Benutzerkonto wurde aktiviert!'
    @body[:url]  = root_url(:host => user.site.host)
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "noreply@gute-arbeit-alleinerziehende.de"
      @subject     = "[Gute Arbeit]"
      @sent_on     = Time.now
      @body[:user] = user
    end
end
