class Recipe < ActiveRecord::Base
  has_one :nutrient_profile, dependent: :destroy
  has_many :recipe_images, dependent: :destroy
  has_many :ingredient_links, dependent: :destroy
  has_many :ingredients, through: :ingredient_links, dependent: :destroy
  has_many :dv_profiles, through: :value_links
  has_many :value_links, dependent: :destroy
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
          { success: true, recipe: recipe }
        else
          { success: false, message: recipe.errors.full_messages[0] }
        end
      end
    end
  end

  def calculate_values!
    targets = Nutrient.where('dv_unit is not null').map do |nutrient|
      { id: nutrient.id, unitwise_method: nutrient.unitwise_method, dv_unit: nutrient.dv_unit, daily_value: nutrient.daily_value / 3, num: 0 }
    end

    r = { recipe: self, value: 0.0, num: 0 }

    r[:recipe].nutrient_profile.servings.each do |serving|
      target = targets.find {|t| t[:id] == serving.nutrient.id}
      if target
        serving_value = Unitwise(serving.value, serving.unit.name).send("to_#{target[:unitwise_method] || target[:dv_unit]}").to_f
        if serving_value < target[:daily_value]
          r[:value] += serving_value / target[:daily_value] unless target[:daily_value] == 0
        else
          r[:value] += target[:daily_value] / serving_value unless serving_value == 0
        end
        r[:num] += 1
      end
    end

    value = r[:value] /= r[:num]
    link = r[:recipe].value_links[0]
    link.update_attribute :value, value
  end

  def self.calculate_values!
    Recipe.includes(:diets, :cuisines, nutrient_profile: { servings: [:unit, :nutrient] }).each {|r| r.calculate_values!}
  end

  def self.meal divider, nums, all_recipes, eaten_recipes=[], attrs={}
    breadth = 1
    recipes = []

    all_recipes = all_recipes.map {|recipe|
      link = ValueLink.where(recipe_id: recipe.id, recipe1_id: eaten_recipes[0].then(:id), recipe2_id: eaten_recipes[1].then(:id))[0]
      { recipe: recipe, value: link.value }
    }.sort_by{|r| -r[:value] }

    while recipes.length < Recipe.count * 0.01 && breadth > 0.1
      breadth -= 0.1
      recipes = all_recipes.select do |recipe|
        recipe[:value] >= all_recipes[0][:value] * breadth &&
        !eaten_recipes.map(&:id).index(recipe[:recipe].id)
      end
    end

    recipe = recipes.shuffle[0][:recipe]
    if recipe
      rsp = { success: true, recipe: recipe }
    else
      rsp = { success: false, message: 'No recipes found' }
    end

    yield(rsp, nums) if block_given?
    rsp
  end

  def self.meals days, meals, attrs={}
    recipes = []

    all_recipes = Recipe.includes(:diets, :cuisines, value_links: :dv_profile)
    all_recipes = all_recipes.where(diets: { name: attrs[:diets] }) if attrs[:diets]
    all_recipes = all_recipes.where(cuisines: { name: attrs[:cuisines] }) if attrs[:cuisines]

    days.times do |d|
      days_recipes = []
      recipes.push []
      meals.times do |m|
        if block_given?
          recipe = self.meal(meals, [d,m], all_recipes, days_recipes, attrs, &Proc.new)[:recipe]
        else
          recipe = self.meal(meals, [d,m], all_recipes, days_recipes, attrs)[:recipe]
        end
        days_recipes.push recipe
        recipes.last.push recipe
      end
    end

    { success: true, recipes: recipes }
  end
end
