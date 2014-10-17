class Email < ActiveRecord::Base
  validates_uniqueness_of :email
  validates_presence_of :email
  validate :email_exists

  def email_exists
	  mx = nil
    domain = email.match(/\@(.+)/)[1]
	  Resolv::DNS.open do |dns|
      mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
	  end
    errors[:base] << 'No valid MX records found' unless mx.size > 0
  end
end
