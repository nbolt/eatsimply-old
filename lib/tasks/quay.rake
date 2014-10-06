url = "https://quay.io/api/v1/repository/eatt/eatt/trigger/d8a0663b-8564-428e-a576-519621ed379e/start"

namespace :quay do
  namespace :build do
    task :develop do
      HTTParty.post(url,{body:'{"branch_name": "develop"}',headers:{'Authorization' => 'Bearer 2yGQVfzc9l9lMEF1Z7buIQVDvk5xtwoWF7um95vV','Content-Type'=>'application/json'}})
    end

    task :master do
      HTTParty.post(url,{body:'{"branch_name": "master"}',headers:{'Authorization' => 'Bearer 2yGQVfzc9l9lMEF1Z7buIQVDvk5xtwoWF7um95vV','Content-Type'=>'application/json'}})
    end
  end
end