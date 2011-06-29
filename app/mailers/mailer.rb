class Mailer < ActionMailer::Base
  default from: "from@example.com"
  
  def session_confirmation(session)
    @session = session
    mail(
      :to => session.user.email,
      :subject => "Confirm Your Session"
    )
  end
  
end
