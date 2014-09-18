require 'raven'

Raven.configure do |config|
  if Rails.env == 'production'
      config.dsn = 'https://79b869d409af4f8199b8519d211a1ee8:0ab4d7d9a04346ab99afe9d57ac6c662@app.getsentry.com/28315'
  elsif Rails.env == 'staging'
      config.dsn = 'https://6faa965d4f6946c1919ffda898de4da6:6eb88614df0d432897d4bbf331d03894@app.getsentry.com/28313'
  end
end