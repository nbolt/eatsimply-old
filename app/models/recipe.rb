class Recipe < ActiveRecord::Base
  has_one :nutrient_profile, dependent: :destroy
  has_many :recipe_images, dependent: :destroy
  has_many :ingredient_links, dependent: :destroy
  has_many :ingredients, through: :ingredient_links, dependent: :destroy
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :cuisines
  has_and_belongs_to_many :diets

  validates_uniqueness_of :yummly_id

  def as_json(options = {})
    super options.merge(include: [:recipe_images])
  end

  def self.import id, attrs
    if Recipe.where(yummly_id: id).first
      { success: false, message: 'Recipe already imported' }
    else
      params = HTTParty.get("http://api.yummly.com/v1/api/recipe/#{id}?_app_id=#{ENV['YUM_API_ID']}&_app_key=#{ENV['YUM_API_KEY']}")
      if !params['id']
        { success: false, message: 'Recipe not found' }
      elsif Recipe.where(yummly_id: params['id']).first
        { success: false, message: 'Recipe already imported' }
      elsif !params['nutritionEstimates'] || !params['nutritionEstimates'][0]
        { success: false, message: 'No nutrition estimates available' }
      else
        recipe = Recipe.new(
          name: params['name'],
          yummly_id: params['id'],
          time: params['totalTimeInSeconds'],
          source: params['source']['sourceRecipeUrl'],
          source_name: params['source']['sourceDisplayName'],
          yield: params['yield'],
          portion_size: params['numberOfServings']
        )
        params['attributes'].merge(attrs).each do |key, attributes| # courses, cuisines, and diets
          if attributes && key != 'holiday'
            attributes.each do |attribute|
              instance = key.capitalize.constantize.where(name: attribute).first
              recipe.send(key.pluralize).push instance if instance
            end
          end
        end
        recipe.nutrient_profile = NutrientProfile.new
        Nutrient.all.each do |nutrient|
          data = params['nutritionEstimates'].find {|n| n['attribute'] == nutrient.attr }
          if data
            serving = recipe.nutrient_profile.servings.build
            serving.nutrient = nutrient
            serving.unit = Unit.where(abbr: data['unit']['abbreviation']).first || Unit.where(name: data['unit']['name']).first
            serving.value = data['value']
            serving.save
          end
        end
        recipe_image = recipe.recipe_images.build
        recipe_image.remote_image_url = params['images'][0]['hostedLargeUrl']
        recipe_image.save
        if recipe.save
          { success: true }
        else
          { success: false, message: recipe.errors.full_messages[0] }
        end
      end
    end
  end

  def self.suggest eaten_recipes
    targets = Nutrient.where(minimize: false).map do |nutrient|
      { id: nutrient.id, unitwise_method: nutrient.unitwise_method, dv_unit: nutrient.dv_unit, value: nutrient.daily_value || 2000 }
    end

    eaten_recipes.each do |recipe|
      recipe.nutrient_profile.servings.each do |serving|
        target = targets.find {|t| t[:id] == serving.nutrient.id }
        if target
          begin
            converted_value = Unitwise(serving.value, serving.unit.abbr_no_period).send("to_#{target[:unitwise_method] || target[:dv_unit]}").to_f
            old_value = target[:value]
            target[:value] -= converted_value
            target[:value] = 0 if target[:value] < 0
          rescue Unitwise::ConversionError
          end
        end
      end
    end

    recipes = (Recipe.includes(nutrient_profile: { servings: [:unit, :nutrient] }) - eaten_recipes).map do |recipe|
      { recipe: recipe, value: 0 }
    end

    recipes.each { |r|
      r[:recipe].nutrient_profile.servings.each do |serving|
        target = targets.find {|t| t[:id] == serving.nutrient.id }
        if target
          begin
            converted_value = Unitwise(serving.value, serving.unit.abbr_no_period).send("to_#{target[:unitwise_method] || target[:dv_unit]}").to_f
            old_value = target[:value]
            new_value = target[:value]
            new_value -= converted_value
            new_value = 0 if new_value < 0
            r[:value] += old_value - new_value
          rescue Unitwise::ConversionError
          end
        end
      end
    }.sort_by!{|r| -r[:value] }
    top_recipes = recipes.select{|r| r[:value] >= recipes[0][:value] * 0.9 }

    top_recipes.shuffle[0][:recipe]
  end
end
