class DataController < ApplicationController
  
  def ingredients
    render json: Ingredient.search(params[:term]).as_json
  end

  def cuisines
    render json: Cuisine.search(params[:term]).map{|c| c if c.recipes[0]}.compact.as_json
  end

  def diets
    render json: Diet.all.select{|d| d.recipes[0]}.as_json + [{'id' => 0, 'name' => 'Omnivore'}]
  end

  def new_recipes
    recipes = Recipe.all.reject {|r| params[:recipes].any? {|n| n==r.id} }
    render json: recipes.as_json
  end

  def restaurants
    if params[:term].present?
      render json: nutritionix_search(params[:term], 1)
    else
      render nothing: true
    end
  end

  def recipes
    email = Email.where(email: params[:email])[0]

    weight =
      case params[:weight_unit]
      when 'metric'   then params[:weight]
      when 'imperial' then params[:weight].convert_to_kg
      end

    height =
      case params[:height_unit]
      when 'metric'   then params[:height]
      when 'imperial' then ((params[:feet] * 12) + params[:height]).convert_to_cm
      end


    bmr =
      if params[:gender][:id] == 'f'
        447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * params[:age].to_i)
      else
        88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * params[:age].to_i)
      end

    bmr *= 1.2 if params[:activity_level][:id].to_i == 0
    bmr *= 1.375 if params[:activity_level][:id].to_i == 1
    bmr *= 1.55 if params[:activity_level][:id].to_i == 2
    bmr *= 1.725 if params[:activity_level][:id].to_i == 3
    bmr *= 1.9 if params[:activity_level][:id].to_i == 4

    if params[:goal][:text] == 'lose'
      bmr -= 500
    elsif params[:goal][:text] == 'gain'
      bmr += 500
    end

    calories = Nutrient.where(name:'Calories')[0]

    attrs = {}
    attrs[:diets] = params[:diet][:id] if params[:diet] && params[:diet][:id].to_i != 0
    attrs[:cuisines] = params[:cuisines].map {|c| Cuisine.find c[:id]} if params[:cuisines]
    attrs[:allergies] = params[:allergies] if params[:allergies]

    opts = {
      bmr: bmr,
      days: params[:days],
      meals: params[:meals],
      key: params[:key],
      cuisines: params[:cuisines] && params[:cuisines].map {|c| Cuisine.find c[:id]} || [],
      attrs: attrs,
      clear_next: params[:clear_next],
      user: email
    }

    if params[:day]
      opts.merge!({
        day: params[:day],
        meal: params[:meal]
      })
    end

    if params[:recipes]
      opts.merge!({
        recipes: params[:recipes]['meals'].map{|m|m['recipes']}.flatten.compact.map{|r| Recipe.find r['recipe']['id']}
      })
    end

    if params[:yummly_id]
      recipe = Recipe.where(yummly_id: params[:yummly_id])[0]
      recipe = Recipe.import(params[:yummly_id])[:recipe] unless recipe
      opts[:recipes].push recipe
    end

    if params[:reset_next]
      opts[:reset_next] = true
    else
      opts[:reset_next] = false
    end

    RecipeJob.new.async.perform opts
    render nothing: true
  end

  def yummly_import
    YummlyJob.new.async.perform params[:yummly_id], params[:email], params[:firebase_key], params[:nums], params[:reset_next]
    render nothing: true
  end

  def restaurant_import
    # check for allergens
    RestaurantJob.new.async.perform params[:id], params[:email], params[:firebase_key], params[:nums], params[:reset_next]
    render nothing: true
  end

  def groceries
    email = Email.where(email: params[:email])[0]
    params[:days].each do |day|
      day['meals'].each do |meal|
        meal['recipes'].each do |recipe|
          recipe[:ingredient_names] = recipe['ingredient_lines'] && JSON.parse(recipe['ingredient_lines']) || recipe['ingredients'].map{|i| i['name']}
        end
      end
    end
    UserMailer.grocery_list_email(email, params[:days]).deliver
    render json: { success: true }
  end

  def groceries_pdf
    recipes = JSON.parse(params[:recipes]).map{|r| r = Recipe.find r; {
      name: r.name,
      ingredients: r.ingredient_lines && JSON.parse(r.ingredient_lines) || r.ingredients.map{|i| i.name}
    }}
    pdf = PDFKit.new((render_to_string 'user_mailer/grocery_list_email', layout: false, locals: { recipes: recipes }), orientation: 'landscape', )
    send_data pdf.to_pdf, filename: "grocery_list.pdf", type: "application/pdf"
  end

  def new_email
    email = Email.where(email: params[:email][:email])[0]
    if email
      render json: { success: true, email_id: email.id }
    else
      email = Email.new(email_params)
      if email.save
        EmailJob.new.async.perform UserMailer.new_email(email)
        render json: { success: true, email_id: email.id }
      else
        render json: { success: false }
      end
    end
  end

  def new_vegas_email
    email = Email.where(email: params[:email][:email])[0]
    if email
      render json: { success: true, email_id: email.id }
    else
      email = Email.new(email_params)
      if email.save
        EmailJob.new.async.perform UserMailer.new_vegas_email(email)
        render json: { success: true, email_id: email.id }
      else
        render json: { success: false }
      end
    end
  end

  private

  def email_params
    params.require(:email).permit(:email, :zip, :comments, :vegas)
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

end
