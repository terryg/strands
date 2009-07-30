class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://strnds.com/users/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://strnds.com/"
  end

  def reset_notification(user)
    setup_email(user)
    @subject += 'Link to reset your password'
    @body[:url] = "http://strnds.com/reset/#{user.reset_code}"
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "noreply@strnds.com"
      @subject     = "[strnds.com] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
