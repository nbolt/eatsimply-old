class RestaurantJob
  include SuckerPunch::Job

  def perform(id, email, key, nums, reset_next)
    ActiveRecord::Base.connection_pool.with_connection do
      email = Email.where(email: email)[0]
      recipe = Recipe.where(nutritionix_id: id)[0]
      if recipe
        rsp = {
          success: true,
          message: nil,
          recipe: recipe,
          nums: nums
        }
      else
        rsp = HTTParty.get("https://api.nutritionix.com/v1_1/item?id=#{id}&appId=#{ENV['NUTRI_API_ID']}&appKey=#{ENV['NUTRI_API_KEY']}")
   
        nutrients = [
          [Nutrient.where(name: 'Calories')[0], 'calories'],
          [Nutrient.where(name: 'Fat')[0], 'total_fat'],
          [Nutrient.where(name: 'Saturated Fat')[0], 'saturated_fat'],
          [Nutrient.where(name: 'Trans Fat')[0], 'trans_fatty_acid'],
          [Nutrient.where(name: 'Cholesterol')[0], 'cholesterol'],
          [Nutrient.where(name: 'Sodium')[0], 'sodium'],
          [Nutrient.where(name: 'Carbohydrates')[0], 'total_carbohydrate'],
          [Nutrient.where(name: 'Fiber')[0], 'dietary_fiber'],
          [Nutrient.where(name: 'Sugars')[0], 'sugars'],
          [Nutrient.where(name: 'Protein')[0], 'protein'],
          [Nutrient.where(name: 'Vitamin A')[0], 'vitamin_a_dv'],
          [Nutrient.where(name: 'Vitamin C')[0], 'vitamin_c_dv'],
          [Nutrient.where(name: 'Calcium')[0], 'calcium_dv'],
          [Nutrient.where(name: 'Iron')[0], 'iron_dv']
        ]

        recipe = Recipe.new(
          name: "#{rsp['brand_name']} - #{rsp['item_name']}",
          nutritionix_id: rsp['item_id'],
          source: "http://nutritionix.com/search/item/#{rsp['item_id']}",
          source_name: 'nutritionix',
          added_by: email.then(:id),
          public: false
        )

        recipe.nutrient_profile = NutrientProfile.new
        Nutrient.all.each do |nutrient|
          serving = recipe.nutrient_profile.servings.build
          serving.nutrient = nutrient
          serving.unit = Unit.where(abbr_no_period: nutrient.dv_unit)[0]
          serving.value = 0
        end

        nutrients.each do |nutrient|
          serving = recipe.nutrient_profile.servings.find {|s| s.nutrient_id == nutrient[0].id}
          if serving
            nutrient[1..-1].each do |field|
              if rsp["nf_#{field}"]
                if nutrient[-1][-3..-1] == '_dv'
                  serving.value += Nutrient.find(nutrient[0]).daily_value * (rsp["nf_#{field}"] / 100.0)
                else
                  serving.value += rsp["nf_#{field}"]
                end
              end
            end
            serving.save
          end
        end

        recipe_image = recipe.recipe_images.build
        recipe_image.remote_image_url = "http://res.cloudinary.com/nutritionix/image/upload/w_360,h_360,c_fit,d_default_abu3if.png/#{rsp['brand_id']}.png"

        if recipe.save
          rsp = {
            success: true,
            message: nil,
            recipe: recipe,
            nums: nums
          }
        else
          rsp = {
            success: false,
            message: recipe.errors.full_messages[0],
            recipe: nil,
            nums: nums
          }
        end
      end

      FirebaseJob.new.perform key, {
        event: 'new-recipe',
        success: rsp[:success],
        recipe: { servings: 1, recipe: rsp[:recipe] },
        message: rsp[:message],
        nums: nums,
        clear_next: false,
        reset_next: reset_next
      }
    end
  end
end