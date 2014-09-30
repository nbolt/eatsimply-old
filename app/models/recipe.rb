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
          { success: true, recipe: recipe }
        else
          { success: false, message: recipe.errors.full_messages[0] }
        end
      end
    end
  end

  def self.meal opts
    breadth = 1
    recipes = []

    targets = Nutrient.where('dv_unit is not null').map do |nutrient|
      orig_daily_value = opts[:profile].servings.find{|s| s.nutrient_id == nutrient.id}.value
      serving_value = opts[:eaten_recipes].compact.map{|r| r.nutrient_profile.servings.find{|s|s.nutrient_id == nutrient.id}.then(:value)}.compact.sum
      remaining_value = orig_daily_value - serving_value
      remaining_value = 0 if remaining_value < 0
      meal_value = orig_daily_value / opts[:meals]
      daily_value = [meal_value, remaining_value].min
      { id: nutrient.id, unitwise_method: nutrient.unitwise_method, dv_unit: nutrient.dv_unit, daily_value: daily_value, num: 0 }
    end

    all_recipes = opts[:all_recipes].map {|recipe| { recipe: recipe, value: 0.0, num: 0 }}
    all_recipes.each_with_index {|r, i|
      if r[:recipe].nutrient_profile
        progress = (i.to_f / all_recipes.count * 100).round
        Pusher.trigger("recipes-#{opts[:key]}", 'recipe-progress', { nums: opts[:nums], progress: progress }) if i % 25 == 0 && opts[:key]
        r[:recipe].nutrient_profile.servings.each do |serving|
          target = targets.find {|t| t[:id] == serving.nutrient.id}
          if target
            if serving.unit.abbr_no_period == target[:dv_unit]
              serving_value = serving.value
            else
              serving_value = Unitwise(serving.value, serving.unit.name).send("to_#{target[:unitwise_method] || target[:dv_unit]}").to_f
            end

            if serving_value < target[:daily_value]
              r[:value] += serving_value / target[:daily_value] unless target[:daily_value] == 0
            else
              r[:value] += target[:daily_value] / serving_value unless serving_value == 0
            end
            r[:num] += 1
          end
        end
      end
      r[:value] /= r[:num]
    }.reject{|r| r[:value].nan? || !r[:recipe].nutrient_profile}.sort_by!{|r| -r[:value]}

    while recipes.length < Recipe.count * 0.1 && breadth > 0.1
      breadth -= 0.1
      recipes = all_recipes.select do |recipe|
        recipe[:value] >= all_recipes[0][:value] * breadth &&
        !opts[:eaten_recipes].map(&:id).index(recipe[:recipe].id)
      end
    end

    recipe = recipes.shuffle[0][:recipe]
    if recipe
      rsp = { success: true, recipe: recipe }
    else
      rsp = { success: false, message: 'No recipes found' }
    end

    yield(rsp, opts[:nums]) if block_given?
    rsp
  end

  def self.meals opts
    recipes = []

    all_recipes = Recipe.includes(:diets, :cuisines, nutrient_profile: { servings: [:unit, :nutrient] })
    all_recipes = all_recipes.where(diets: { name: attrs[:diets] }) if opts[:attrs][:diets]
    all_recipes = all_recipes.where(cuisines: { name: attrs[:cuisines] }) if opts[:attrs][:cuisines]

    opts[:days].times do |d|
      days_recipes = []
      recipes.push []
      opts[:meals].times do |m|
        meal_opts = {
          key: opts[:key],
          profile: opts[:profile],
          meals: opts[:meals],
          nums: [d,m],
          all_recipes: all_recipes,
          eaten_recipes: days_recipes || []
        }

        if block_given?
          recipe = self.meal(meal_opts, &Proc.new)[:recipe]
        else
          recipe = self.meal(meal_opts)[:recipe]
        end

        days_recipes.push recipe
        recipes.last.push recipe
      end
    end

    { success: true, recipes: recipes }
  end
end
