class User < ActiveRecord::Base
  authenticates_with_sorcery!

  def full_name
    nil
  end

  def first_name
    nil
  end

  def last_name
    nil
  end
end
