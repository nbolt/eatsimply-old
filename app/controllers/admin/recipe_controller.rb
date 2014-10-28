class Admin::RecipeController < AdminController

  expose(:recipe) { Recipe.where(id: params[:id])[0] }

  def info
    if Settings.first && Settings.first.recipe_cache
      render json: Settings.first.recipe_cache
    else
      rsp = HTTParty.get("http://api.yummly.com/v1/api/recipe/#{params[:recipe_id]}?_app_id=#{ENV['YUM_API_ID']}&_app_key=#{ENV['YUM_API_KEY']}")
      Settings.first.update_attribute :recipe_cache, rsp.as_json if Rails.env == 'development' && Settings.chain(:first, :cache_recipe)
      render json: rsp
    end
  end

  def unit
    u = Unit.where(id: params[:id]).first
    if u
      render json: u
    else
      render json: { _id: params[:id], name: params[:id], abbr: params[:id] }
    end
  end

  def view
  end

  def destroy
    recipe.destroy
    render nothing: true
  end

  def recipes
    if params[:page]
      render json: Kaminari.paginate_array(Recipe.all.sort_by(&:algo_count).reverse).page(params[:page]).per(30)
    else
      render json: Recipe.all.sort_by(&:algo_count).reverse
    end
  end

  def import
    Recipe.import params[:id]
    render json: { success: true }
  end

  def create
    if params[:id].present? && Recipe.where(yummly_id: params[:id]).first
      render json: { success: false, message: 'Recipe exists' }
    else
      begin
        recipe = Recipe.create(
          name: params[:name],
          yummly_id: params[:id],
          time: params[:totalTimeInSeconds],
          source: params[:source].then(:sourceRecipeUrl),
          source_name: params[:source].then(:sourceDisplayName),
          yield: params[:yield],
          portion_size: params[:numberOfServings],
          instructions: params[:instructions],
          public: false
        )
        params[:attributes].each do |key, attributes| # courses, cuisines, and diets
          if attributes && ['diets', 'cuisines', 'courses'].index(key)
            attributes.each do |attribute|
              recipe.send(key).push key[0..-2].capitalize.constantize.where(name: attribute['text'])[0]
            end
          end
        end
        recipe.nutrient_profile = NutrientProfile.new
        Nutrient.all.each do |nutrient|
          serving = recipe.nutrient_profile.servings.build
          serving.nutrient = nutrient
          serving.value = 0
        end
        params[:ingredients].each do |i|
          if i[:profile]
            i[:amount] = i[:amount].to_frac
            ingredient = Ingredient.find_or_create_by(name: i[:profile][:text])
            ingredient.recipes.push recipe
            ilink = IngredientLink.where(ingredient_id: ingredient.id, recipe_id: recipe.id)[0]
            ilink.update_attribute :description, i[:notes]
            unit = Unit.where(id: i.chain(:unit, :id)).first
            unless unit
              unit = Unit.where(name: i.chain(:unit, :text)).first || Unit.where(abbr: i.chain(:unit, :abbr)).first
              unit = Unit.where(abbr_no_period: i.chain(:unit, :abbr)).first if !unit && i.chain(:unit, :abbr)
              if unit
                i[:amount] *= i[:unit][:multiplier]
                i[:unit][:multiplier] = 1
              end
            end
            unit = Unit.create(name: i[:unit][:text], abbr: i[:unit][:abbr], generic: false) unless unit
            link = IngredientsUnits.where(ingredient_id: ingredient.id, unit_id: unit.id)[0]
            unless link
              unit.ingredients.push ingredient
              link = IngredientsUnits.where(ingredient_id: ingredient.id, unit_id: unit.id)[0]
            end
            data = i[:combinedData]["#{i[:profile][:text]}"].find{|d|d[:_id] == i[:unit][:id]}
            unless ingredient.id
              [:eggs, :tree_nuts, :shellfish, :peanuts, :wheat, :gluten, :fish, :soybeans, :milk].each do |allergen|
                ingredient["allergen_contains_#{allergen}"] = data["allergen_contains_#{allergen}"]
              end       
            end
            unless link.nutrient_profile
              link.nutrient_profile = NutrientProfile.new
              rsp = nutritionix_item(data['_id'])
              usda = rsp['usda_fields']
              if usda
                Nutrient.all.each do |nutrient|
                  if usda[nutrient.attr]
                    serving = link.nutrient_profile.servings.build
                    serving.nutrient = nutrient
                    if nutrient.name == 'Trans Fat'
                      fasat = usda['FASAT'] && usda['FASAT']['value'] || 0
                      fams  = usda['FAMS'] && usda['FAMS']['value'] || 0
                      fapu  = usda['FAMS'] && usda['FAPU']['value'] || 0
                      fat   = usda['FAMS'] && usda['FAT']['value'] || 0
                      serving.value = fat - (fapu + fams + fasat)
                      serving.unit = Unit.where(abbr: usda['FAT']['uom']).first || Unit.where(abbr_no_period: usda['FAT']['uom']).first
                    else
                      serving.value = usda[nutrient.attr]['value']
                      serving.unit = Unit.where(abbr: usda[nutrient.attr]['uom'])[0] || Unit.where(abbr_no_period: usda[nutrient.attr]['uom'])[0]
                    end
                    serving.value *= i[:unit][:multiplier] * i[:amount] if i.chain(:unit, :multiplier)
                    serving.save
                    recipe_serving = recipe.nutrient_profile.servings.find {|s| s.nutrient_id == nutrient.id}
                    recipe_serving.unit = serving.unit
                    recipe_serving.value += serving.value
                    recipe_serving.save
                  end
                end
              else
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

                Nutrient.all.each do |nutrient|
                  serving = link.nutrient_profile.servings.build
                  serving.nutrient = nutrient
                  serving.unit = Unit.where(abbr_no_period: nutrient.dv_unit)[0]
                  serving.value = 0
                end

                nutrients.each do |nutrient|
                  serving = link.nutrient_profile.servings.find {|s| s.nutrient_id == nutrient[0].id}
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
                    recipe_serving = recipe.nutrient_profile.servings.find {|s| s.nutrient_id == nutrient[0].id}
                    recipe_serving.unit = serving.unit
                    recipe_serving.value += serving.value
                    recipe_serving.save
                  end
                end
              end
              link.save
            end
            ingredient.save
          end
        end
        if params[:images].chain(:first, :hostedLargeUrl)
          recipe_image = recipe.recipe_images.build
          recipe_image.remote_image_url = params[:images][0][:hostedLargeUrl]
          recipe_image.save
        elsif params[:photo]
          recipe_image = recipe.recipe_images.build
          recipe_image.remote_image_url = params[:photo]        
          HTTParty.post("#{params[:photo]}/remove?key=#{ENV['FILEPICKER_KEY']}") if recipe_image.save
        end
        if recipe.save
          render json: { success: true, id: recipe.id }
        else
          render json: { success: false, message: recipe.errors.full_messages[0] }
        end
      rescue Exception => e
        recipe.destroy
        raise e
      end
    end
  end

  def parse_line
    matches = params[:line].match(/^(\d+( ?[\d\/]+)?) (\w+) (.*)/)
    if matches
      unit = unit?(matches[3])
      results = Ingredient.search matches[4]
      render json: {
        amount: matches[1],
        unit: unit && unit.id,
        name: results[0] && results[0].name
      }
    else
      results = Ingredient.search params[:line]
      render json: {
        amount: nil,
        unit: nil,
        name: results[0] && results[0].name
      }
    end
  end

  def courses
    render json: Course.all.as_json
  end

  def cuisines
    render json: Cuisine.all.as_json
  end

  def diets
    render json: Diet.all.as_json
  end

  def units
    render json: Unit.search(params[:term]).as_json
  end

  def unitData
    unitList = []
    params[:units].each do |u|
      unit = Unit.where(name: u['name']).first.as_json || { name: u['name'] }
      unit.merge!({ '_id' => u['id'], multiplier: u['multiplier'] })
      unitList.push unit
    end
    render json: unitList
  end

  def ingredients
    render json: Ingredient.search(params[:term]).as_json
  end

  def nutritionix
    if params[:term].present?
      data = nutritionix_search(params[:term], 3)
      data = nutritionix_search(params[:term], 2) unless data[0]
      render json: data
    else
      render nothing: true
    end
  end

private

  def unit? unit
    Unit.all.each do |u|
      4.times do |i|
        case i
        when 0 then w = u.name
        when 1 then w = u.name.pluralize
        when 2 then w = u.abbr
        when 3 then w = u.abbr && u.abbr.pluralize
        end
        return u if unit == w
      end
    end
    return nil
  end

  def nutritionix_search query, item_type
    rsp = HTTParty.post(
      "https://api.nutritionix.com/v1_1/search",
      {
        query: {
          appId: ENV['NUTRI_API_ID'],
          appKey: ENV['NUTRI_API_KEY'],
          limit: 50,
          fields: ['*'],
          query: query,
          filters: {
            item_type: item_type
          }
        }
      }
    )
    rsp['hits']
  end

  def nutritionix_item id
    HTTParty.get "https://api.nutritionix.com/v1_1/item?id=#{id}&appId=#{ENV['NUTRI_API_ID']}&appKey=#{ENV['NUTRI_API_KEY']}"
  end

end
