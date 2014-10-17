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

  def recipes
    bmr =
      if params[:gender][:id] == 'f'
        447.593 + (9.247 * params[:weight].to_i) + (3.098 * params[:height].to_i) - (4.330 * params[:age].to_i)
      else
        88.362 + (13.397 * params[:weight].to_i) + (4.799 * params[:height].to_i) - (5.677 * params[:age].to_i)
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
      clear_next: params[:clear_next]
    }

    if params[:day]
      opts.merge!({
        day: params[:day],
        meal: params[:meal]
      })
    end

    if params[:recipes]
      opts.merge!({
        recipes: params[:recipes]['meals'].map{|m|m['recipes']}.flatten.compact.map{|r|Recipe.find r['id']}
      })
    end

    RecipeJob.new.async.perform opts
    render nothing: true
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

end
