class UserMailer < ActionMailer::Base

  def new_email(email)
    mail(subject: "Thanks from Eatt!", to: email.email, from: 'support@ea.tt')
  end

  def new_vegas_email(email)
    mail(subject: "Thanks from Eatt!", to: email.email, from: 'support@ea.tt')
  end

end