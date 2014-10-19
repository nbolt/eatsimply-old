class FirebaseJob
  include SuckerPunch::Job

  def perform(key, values)
    HTTParty.post("#{ENV['FIREBASE_URL']}/#{key}.json?auth=#{ENV['FIREBASE_SECRET']}", { body: values.to_json })
  end
end