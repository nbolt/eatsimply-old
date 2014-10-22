class RestaurantJob
  include SuckerPunch::Job

  def perform(id, key, nums, reset_next)
    ActiveRecord::Base.connection_pool.with_connection do
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
          [4, 'calories'],
          [5, 'total_fat'],
          [21, 'saturated_fat'],
          [6, 'trans_fatty_acid'],
          [21, 'monounsaturated_fat', 'polyunsaturated_fat'],
          [7, 'cholesterol'],
          [8, 'sodium'],
          [9, 'total_carbohydrate'],
          [10, 'dietary_fiber'],
          [11, 'sugars'],
          [13, 'protein'],
          [12, 'vitamin_a_dv'],
          [14, 'vitamin_c_dv'],
          [1, 'calcium_dv'],
          [3, 'iron_dv']
        ]

        recipe = Recipe.new(
          name: "#{rsp['brand_name']} - #{rsp['item_name']}",
          nutritionix_id: rsp['item_id'],
          source: "http://nutritionix.com/search/item/#{rsp['item_id']}",
          source_name: 'nutritionix',
          portion_size: rsp['nf_serving_size_qty'],
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
          serving = recipe.nutrient_profile.servings.where(nutrient_id: nutrient[0])[0]
          if serving
            nutrient[1..-1].each do |field|
              if rsp["nf_#{field}"][-3..-1] == '_dv'
                serving.value += Nutrient.find(nutrient[0]).daily_value * (rsp["nf_#{field}"] / 100.0)
              else
                serving.value += rsp["nf_#{field}"]
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
        recipe: rsp[:recipe],
        message: rsp[:message],
        nums: nums,
        clear_next: false,
        reset_next: reset_next
      }
    end
  end
end