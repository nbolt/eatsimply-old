class UserMailer < ActionMailer::Base

  def new_email email
  	mail(subject: "Thanks from Eatt!", to: email.email, from: 'support@ea.tt', tag: 'welcome-preview', track_opens: true)
  end

  def new_vegas_email email
  	mail(subject: "Thanks from Eatt!", to: email.email, from: 'support@ea.tt', tag: 'welcome-preview', track_opens: true)
  end

  def grocery_list_email email, recipes
    @recipes = recipes
    mail(subject: "Your customized meal plan!", to: email.email, from: 'support@ea.tt', tag: 'meal-plan', track_opens: true)
  end

end