class MailchimpJob
  include SuckerPunch::Job

  def perform(email)
    gb = Gibbon::API.new(ENV['MAILCHIMP_API'])
    gb.lists.subscribe({:id => 'ee35460d90', :email => {:email => email}, :double_optin => false})
  end
end