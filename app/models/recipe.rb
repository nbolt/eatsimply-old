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
            serving.unit = Unit.where(abbr: data['unit']['abbreviation']).first || Unit.where(abbr_no_period: data['unit']['abbreviation']).first || Unit.where(name: data['unit']['name']).first
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

  def self.meal recipes=[], attrs={}
    targets = Nutrient.where('dv_unit is not null').map do |nutrient|
      { id: nutrient.id, unitwise_method: nutrient.unitwise_method, dv_unit: nutrient.dv_unit, daily_value: nutrient.daily_value || 2000, num: 0 }
    end

    all_recipes = Recipe.includes(:diets, :cuisines, nutrient_profile: { servings: [:unit, :nutrient] })
    all_recipes = all_recipes.where('id != ?', recipes.map(&:id)) if recipes[0]
    all_recipes = all_recipes.where(diets: { name: attrs[:diets] }) if attrs[:diets]
    all_recipes = all_recipes.where(cuisines: { name: attrs[:cuisines] }) if attrs[:cuisines]

    recipes = all_recipes.map {|recipe| { recipe: recipe, value: 0.0, num: 0 }}
    recipes.each {|r|
      r[:recipe].nutrient_profile.servings.each do |serving|
        target = targets.find {|t| t[:id] == serving.nutrient.id}
        if target
          begin
          serving_value = Unitwise(serving.value, serving.unit.name).send("to_#{target[:unitwise_method] || target[:dv_unit]}").to_f
          r[:value] += serving_value / target[:daily_value]
          r[:num] += 1
          rescue Unitwise::ConversionError
            binding.pry
          end
        end
      end
    }.map!{|r| -r[:value] /= r[:num]}.sort_by!{|r| r[:value] }.select{|r| r[:value] >= recipes[0][:value] * 0.9 }.shuffle[0]
    binding.pry
  end

  def self.suggest num, attrs=nil
    recipes = []

    targets = Nutrient.where("dv_unit is not null and dv_unit != ? and dv_unit != ?", 'IU').map do |nutrient|
      daily_value = Unitwise(nutrient.daily_value || 2000, nutrient.unitwise_method || nutrient.dv_unit).to_milligram.to_f
      { id: nutrient.id, unitwise_method: nutrient.unitwise_method, dv_unit: nutrient.dv_unit, value: daily_value, orig_value: daily_value }
    end

    all_recipes = Recipe.includes(:diets, :cuisines, nutrient_profile: { servings: [:unit, :nutrient] }).where(portion_size: 1)
    all_recipes = all_recipes.where(diets: { name: attrs[:diets] }) if attrs[:diets]
    all_recipes = all_recipes.where(cuisines: { name: attrs[:cuisines] }) if attrs[:cuisines]
    
    num.times do
     recipes.each {|r|
        if r
          r[:recipe].nutrient_profile.servings.each do |serving|
            target = targets.find {|t| t[:id] == serving.nutrient.id }
            if target
              serving_value = Unitwise(serving.value, serving.unit.abbr_no_period).to_milligram.to_f
              target[:value] -= serving_value
              target[:value] = 0 if target[:value] < 0
            end
          end
        end
      }

      new_recipes = (all_recipes - recipes).map { |recipe| { recipe: recipe, pvalue: 0, nvalue: 0 } }
      new_recipes.each { |r|
        r[:recipe].nutrient_profile.servings.each do |serving|
          target = targets.find {|t| t[:id] == serving.nutrient.id }
          if r && target
            serving_value = Unitwise(serving.value, serving.unit.abbr_no_period).to_milligram.to_f
            target_value  = target[:value]
            orig_value    = target[:orig_value]
            recipe_value = target_value < serving_value && target_value || serving_value
            if serving.nutrient.minimize
              r[:nvalue] += serving_value
            else
              r[:pvalue] += recipe_value
            end
            r = nil if serving_value > target[:orig_value] / 2
          end
        end
      }.compact!.sort_by!{|r| -r[:pvalue] }
      
      recipes.push new_recipes.select{|r| r[:pvalue] >= new_recipes[0][:value] * 0.9 }.shuffle[0]
    end

    if recipes.length >= num
      { success: true, recipes: recipes.map{|r|r[:recipe]} }
    elsif top_recipes.length > 0
      { success: false, message: "Only #{recipes.length} recipes found", recipes: recipes.map{|r|r[:recipe]} }
    elsif top_recipes.length == 0
      { success: false, message: "No recipes found", recipes: [] }
    else
      { success: false, message: "Sorry, something seems to have gone wrong.", recipes: [] }
    end
  end
end
