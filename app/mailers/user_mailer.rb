class UserMailer < ActionMailer::Base

  def new_email(email)
    mail(subject: "An enquiry from Chris", to: 'c@chrisbolton.me', from: 'support@ea.tt', reply_to: email.email)
  end

  def new_vegas_email(email)
    mail(subject: "An enquiry from Chris", to: 'c@chrisbolton.me', from: 'support@ea.tt', reply_to: email.email)
  end

end