url = "https://quay.io/api/v1/repository/eatt/eatt/trigger/2737c4a0-76fd-4697-a05a-ac1b2301844c/start"

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