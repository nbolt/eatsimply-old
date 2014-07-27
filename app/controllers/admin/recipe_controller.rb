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

  def create
    # process nutritionEstimates
  end

  def parse_line
    matches = params[:line].match(/^(\d+( [\d\/]+)?) (\w+) (.*)/)
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

  def units
    render json: Unit.all.as_json
  end

  def ingredients
    render json: Ingredient.search(params[:term]).as_json
  end

  def nutrient_profiles
    #render json: ActiveNutrition.search(params[:term]).as_json(methods: [:ndb_number, :name])
    render json: nutritionix(params[:term])
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

  def nutritionix query
    rsp = HTTParty.post(
      "https://api.nutritionix.com/v1_1/search",
      {
        query: {
          appId: ENV['NUTRITIONIX_API_ID'],
          appKey: ENV['NUTRITIONIX_API_KEY'],
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

end
