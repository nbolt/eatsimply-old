namespace :yummly do
  task :import do
    MAXRESULT = 10
    cuisine = nil
    (Course.where(name:['Main Dishes', 'Lunch and Snacks', 'Breakfast and Brunch']) + [nil]).each do |course|
      Nutrient.where(yummly_supported: true, minimize: false).each do |nutrient|
        unless nutrient.name == 'Calories'
          (Diet.where(name: ['Vegan', 'Vegetarian']) + [nil]).each do |diet|
            url = "http://api.yummly.com/v1/api/recipes?_app_id=#{ENV['YUM_API_ID']}&_app_key=#{ENV['YUM_API_KEY']}&requirePictures=true&maxResult=20&start=0"
            url += "&allowedCuisine[]=#{cuisine.yummly_attr}" if cuisine
            url += "&allowedDiet[]=#{diet.yummly_attr}" if diet
            url += "&allowedCourse[]=#{course.yummly_attr}" if course
            converted_value = Unitwise(nutrient.daily_value, nutrient.dv_unit).send("to_#{nutrient.unitwise_method || nutrient.yummly_unit}").to_f
            url += "&nutrition.#{nutrient.attr}.min=#{converted_value / 3.5}"
            url += "&nutrition.#{nutrient.attr}.max=#{converted_value}"
            yum = HTTParty.get(URI::escape url)
            imports = 0; tries = 0; start = 0
            while imports < MAXRESULT && yum['matches']
              if yum['matches'][tries]
                attrs = { 'diet' => [] }
                attrs['diet'].push diet.name if diet
                attrs['diet'].push 'Vegetarian' if diet && diet.name == 'Vegan'
                rsp = Recipe.import yum['matches'][tries]['id'], attrs
                tries += 1
                puts '------------'
                if rsp[:success]
                  imports += 1
                  puts "#{Recipe.count}: #{rsp[:recipe].name}"
                else
                  puts rsp[:message]
                end
                puts '------------'
              else
                start += tries
                tries = 0
                yum = HTTParty.get(URI::escape url.gsub(/start=\d+/, "start=#{start}"))
              end
            end
          end
        end
      end
    end
  end
end