class Admin::RecipeController < AdminController

  def info
    if Settings.first.recipe_cache
      render json: Settings.first.recipe_cache
    else
      rsp = HTTParty.get("http://api.yummly.com/v1/api/recipe/#{params[:recipe_id]}?_app_id=#{ENV['YUM_API_ID']}&_app_key=#{ENV['YUM_API_KEY']}")
      Settings.first.update_attribute :recipe_cache, rsp.as_json unless Rails.env == 'production'
      render json: rsp
    end
  end

  def unit
    u = Unit.where(id: params[:id]).first
    if u
      render json: u
    else
      render json: { id: params[:id], name: params[:id], abbr: params[:id] }
    end
  end

  def creates
    binding.pry
    render nothing: true
  end

  def create
    recipe = Recipe.new(
      name: params[:name],
      yummly_id: params[:id],
      time: params[:totalTimeInSeconds],
      source: params[:source][:sourceRecipeUrl],
      source_name: params[:source][:sourceDisplayName],
      yield: params[:yield],
      portion_size: params[:numberOfServings]
    )
    params[:attributes].each do |key, attributes|
      if attributes
        attributes.each do |attribute|
          recipe.send(key).push key[0..-2].capitalize.constantize.find(attribute['id'])
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
        ingredient = Ingredient.where(name: i[:profile][:text]).first ||
                     Ingredient.new(name: i[:profile][:text])
        ingredient.recipes.push recipe
        unit = Unit.where(name: i[:unit][:text]).first ||
               Unit.new(name: i[:unit][:text], abbr: i[:unit][:abbr])
        unit.ingredients.push ingredient
        link = IngredientsUnits.where(ingredient_id: ingredient.id, unit_id: unit.id).first ||
               !unit.id && unit.ingredients_units.first || !ingredient.id && ingredient.ingredients_units.first
        unless ingredient.id
          data = i[:combinedData]["#{i[:profile][:text]}"].find{|d|d[:fields][:nf_serving_size_unit] == i[:unit][:text]}
          [:eggs, :tree_nuts, :shellfish, :peanuts, :wheat, :gluten, :fish, :soybeans, :milk].each do |allergen|
            ingredient["allergen_contains_#{allergen}"] = data["allergen_contains_#{allergen}"]
          end       
        end
        unless link.nutrient_profile
          link.nutrient_profile = NutrientProfile.new
          usda = nutritionix_item(i[:combinedData]["#{i[:profile][:text]}"][0]['_id'])['usda_fields']
          Nutrient.all.each do |nutrient|
            if usda[nutrient.attr]
              serving = link.nutrient_profile.servings.build
              serving.nutrient = nutrient
              if nutrient.name == 'Trans Fat'
                fasat = usda['FASAT']['value']
                fams  = usda['FAMS']['value']
                fapu  = usda['FAPU']['value']
                fat   = usda['FAT']['value']
                serving.value = fat - (fapu + fams + fasat)
                serving.unit = Unit.where(abbr: usda['FAT']['uom']).first
              else
                serving.value = usda[nutrient.attr]['value']
                serving.unit = Unit.where(abbr: usda[nutrient.attr]['uom']).first
              end
              serving.value = serving.value * i[:amount].to_frac
              serving.save
              recipe_serving = recipe.nutrient_profile.servings.find {|s| s.nutrient_id == nutrient.id }
              recipe_serving.unit = serving.unit
              recipe_serving.value += serving.value
              recipe_serving.save
            end
          end
          link.save
        end
        ingredient.save
      end
    end
    recipe_image = recipe.recipe_images.build
    recipe_image.remote_image_url = params[:images][0][:hostedLargeUrl]
    recipe_image.save
    if recipe.save
      render json: { success: true }
    else
      render json: { success: false }
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
    params[:units].each do |unit_name|
      unit = Unit.where(name: unit_name).first || { name: unit_name }
      unitList.push unit
    end
    render json: unitList
  end

  def ingredients
    render json: Ingredient.search(params[:term]).as_json
  end

  def nutritionix
    render json: nutritionix_search(params[:term])
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

  def nutritionix_search query
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
            item_type: 3
          }
        }
      }
    )
    rsp['hits']
  end

  def nutritionix_item id
    HTTParty.get(
      "https://api.nutritionix.com/v1_1/item?id=#{id}&appId=#{ENV['NUTRI_API_ID']}&appKey=#{ENV['NUTRI_API_KEY']}",
    )
  end

end
