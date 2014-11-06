class Recipe < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, against: :name, using: { tsearch: { prefix: true } }

  has_one :nutrient_profile, dependent: :destroy
  has_many :recipe_images, dependent: :destroy
  has_many :ingredient_links, dependent: :destroy
  has_many :ingredients, through: :ingredient_links, dependent: :destroy
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :cuisines
  has_and_belongs_to_many :diets

  #validates_uniqueness_of :yummly_id, allow_nil: true
  validates_uniqueness_of :nutritionix_id, allow_nil: true

  def as_json(options = {})
    super options.merge(include: [:recipe_images, :courses, :cuisines, :diets, :ingredient_links, :ingredients])
  end

  def self.no_ingredients
    where(<<-SQL)
      NOT EXISTS (SELECT 1 
        FROM   ingredient_links
        WHERE  recipes.id = ingredient_links.recipe_id) 
    SQL
  end
  
  def self.import id, attrs={}, opts={}
    if Recipe.where(yummly_id: id).first
      { success: false, message: 'Recipe already imported' }
    else
      opts[:public] ||= false
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
          portion_size: params['numberOfServings'],
          ingredient_lines: params['ingredientLines'].to_json,
          public: opts[:public]
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
          { success: false, message: recipe.errors.full_messages[0], recipe: Recipe.where(yummly_id: id)[0] }
        end
      end
    end
  end

  def self.nutrient_values bmr, recipes
    targets = Nutrient.where('dv_unit is not null and daily_value is not null').map do |nutrient|
      { nutrient: nutrient, value: bmr / 2000.0 * nutrient.daily_value }
    end

    targets.map! do |target|
      values = recipes.map do |r|
        serving = r[:recipe].nutrient_profile.servings.find{|s| s.nutrient_id == target[:nutrient].id}
        if serving && serving.unit.abbr != 'IU'
          value = Unitwise(serving.value, serving.unit.abbr_no_period).send("to_#{target[:nutrient].unitwise_method || target[:nutrient].dv_unit}").to_f
          value * r[:servings]
        else
          nil
        end
      end
      [((values.compact.sum / target[:value]).round(2) * 100).to_i, target[:nutrient].name]
    end
  end

  def self.meal opts
    breadth = 1
    recipes = []
    final_recipes = []
    recipe_count = opts[:all_recipes].count

    targets = Nutrient.where('dv_unit is not null').where(yummly_supported: true).map do |nutrient|
      orig_daily_value = opts[:bmr] / 2000.0 * nutrient.daily_value
      serving_value = opts[:days_eaten_recipes].compact.map{|r| v=r[:recipe].nutrient_profile.servings.find{|s|s.nutrient_id == nutrient.id}.then(:value); v && v * r[:servings] || nil}.compact.sum
      remaining_value = orig_daily_value - serving_value
      remaining_value = 0 if remaining_value < 0 && !nutrient.prime
      meal_value = orig_daily_value / opts[:meals]
      daily_value = [meal_value, remaining_value].min
      { id: nutrient.id, unitwise_method: nutrient.unitwise_method, dv_unit: nutrient.dv_unit, daily_value: daily_value, num: 0 }
    end

    all_recipes = opts[:all_recipes].map {|recipe| [{ recipe: recipe, value: 0.0, num: 0, servings: 1 }, { recipe: recipe, value: 0.0, num: 0, servings: 2 }]}.flatten
    all_recipes.each_with_index do |r, i|
      if r[:recipe].nutrient_profile
        progress = (i.to_f / all_recipes.count * 100).round
        if i % (recipe_count / 10) == 0 && opts[:key]
          #FirebaseJob.new.async.perform "recipes-#{opts[:key]}", { event: 'recipe-progress', nums: opts[:nums], progress: progress }
        end
        r[:recipe].nutrient_profile.servings.each do |serving|
          target = targets.find {|t| t[:id] == serving.nutrient.id}
          if target && serving.nutrient.prime
            if serving.unit.abbr_no_period == target[:dv_unit]
              serving_value = serving.value
            else
              serving_value = Unitwise(serving.value, serving.unit.name).send("to_#{target[:unitwise_method] || target[:dv_unit]}").to_f
            end
            serving_value *= r[:servings]

            unless serving.nutrient.minimize
              if serving_value < target[:daily_value]
                r[:value] += serving_value / target[:daily_value] unless target[:daily_value] == 0
              else
                r[:value] += target[:daily_value] / serving_value unless serving_value == 0
              end
            end
            r[:num] += 1
          end
        end
      end
      r[:value] /= r[:num]
    end
    all_recipes = all_recipes.reject{|r| r[:value].nan? || !r[:recipe].nutrient_profile}.sort_by{|r| -r[:value]}

    while recipes.length < Recipe.count * 0.1 && breadth > 0.1
      breadth -= 0.1
      recipes = all_recipes.select do |recipe|
        recipe[:value] >= all_recipes[0][:value] * breadth &&
        (opts[:all_eaten_recipes].empty? && true || !opts[:all_eaten_recipes].map{|r| r[:recipe].id}.index(recipe[:recipe].id))
      end
    end

    if opts[:cuisines].present?
      _recipes = recipes.reject {|r| (r[:recipe].cuisines & opts[:cuisines]).empty?}
      recipes = _recipes if _recipes[0]
    end

    targets.each {|target| target[:daily_value] = 0 if target[:daily_value] < 0}
    recipes.each do |r|
      r[:value] = 0
      r[:recipe].nutrient_profile.servings.each do |serving|
        target = targets.find {|t| t[:id] == serving.nutrient.id}
        if target && !serving.nutrient.prime
          if serving.unit.abbr_no_period == target[:dv_unit]
            serving_value = serving.value
          else
            serving_value = Unitwise(serving.value, serving.unit.name).send("to_#{target[:unitwise_method] || target[:dv_unit]}").to_f
          end
          serving_value *= r[:servings]

          unless serving.nutrient.minimize
            if serving_value < target[:daily_value]
              r[:value] += serving_value / target[:daily_value] unless target[:daily_value] == 0
            else
              r[:value] += target[:daily_value] / serving_value unless serving_value == 0
            end
          end

          r[:num] += 1
        end
      end
      r[:value] /= r[:num]
    end
    recipes = recipes.sort_by{|r| -r[:value]}

    breadth = 1
    while final_recipes.length < recipes.length * 0.1 && breadth > 0.1
      breadth -= 0.1
      final_recipes = recipes.select do |recipe|
        recipe[:value] >= recipes[0][:value] * breadth
      end
    end

    r = final_recipes.shuffle[0]
    r = recipes.shuffle[0] unless r
    if r
      r[:recipe].update_attribute :algo_count, r[:recipe].algo_count + 1
      rsp = { success: true, recipe: { recipe: r[:recipe], servings: r[:servings] } }
    else
      rsp = { success: false, message: 'No recipes found.' }
      eOpts = opts.merge({
        days_eaten_recipes: opts[:days_eaten_recipes].map{|r|r[:recipe].id},
        all_eaten_recipes: opts[:all_eaten_recipes].map{|r|r[:recipe].id}
      })
      eOpts.delete(:all_recipes)
      Appsignal.send_exception(RecipeNotFound.new(eOpts))
    end

    yield(rsp, opts[:nums], opts[:clear_next]) if block_given?
    rsp
  end

  def self.meals opts
    recipes = []

    all_recipes = Recipe.includes(:ingredients, :diets, :cuisines, nutrient_profile: { servings: [:unit, :nutrient] })
    if opts[:user]
      all_recipes = all_recipes.where("public is true or added_by = ?", opts[:user].id)
    else
      all_recipes = all_recipes.where(public: true)
    end
    all_recipes = all_recipes.where(diets: { id: opts[:attrs][:diets] }) if opts[:attrs][:diets]
    all_recipes = all_recipes.where(veganize: nil) if opts[:attrs][:diets] && opts[:attrs][:diets].to_i != 1

    opts[:days].times do |d|
      days_recipes = opts[:recipes] || []
      recipes.push []
      opts[:meals].times do |m|
        nums = opts[:day] && [opts[:day], opts[:meal]] || [d,m]
        meal_opts = {
          bmr: opts[:bmr],
          key: opts[:key],
          meals: opts[:meals],
          nums: nums,
          cuisines: opts[:attrs][:cuisines],
          all_recipes: all_recipes,
          days_eaten_recipes: days_recipes || [],
          all_eaten_recipes: recipes.flatten || [],
          clear_next: opts[:clear_next]
        }

        if block_given?
          recipe = self.meal(meal_opts, &Proc.new)
        else
          recipe = self.meal(meal_opts)
        end
        # handle recipe not found
        if recipe[:success]
          days_recipes.push recipe[:recipe]
          recipes.last.push recipe[:recipe]
        end
      end
    end

    { success: true, recipes: recipes }
  end
end
