class UserMailer < ActionMailer::Base

  def new_email email
    mailchimp(email.email) if Rails.env == 'production'
  	mail(subject: "Thanks from Eatt!", to: email.email, from: 'support@ea.tt', tag: 'welcome-preview', track_opens: true)
  end

  def new_vegas_email email
    mailchimp(email.email) if Rails.env == 'production'
  	mail(subject: "Thanks from Eatt!", to: email.email, from: 'support@ea.tt', tag: 'welcome-preview', track_opens: true)
  end

  def grocery_list_email email, days
    @days = days
    mail(subject: "Your customized meal plan!", to: email.email, from: 'support@ea.tt', tag: 'meal-plan', track_opens: true)
  end

  private

  def mailchimp email
    MailchimpJob.new.async.perform email
  end

end