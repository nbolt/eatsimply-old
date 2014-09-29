class DataController < ApplicationController
  
  def ingredients
    render json: Ingredient.search(params[:term]).as_json
  end

  def cuisines
    render json: Cuisine.search(params[:term]).as_json
  end

  def new_recipes
    recipes = Recipe.all.reject {|r| params[:recipes].any? {|n| n==r.id} }
    render json: recipes.as_json
  end

  def recipes
    RecipeJob.new.async.perform params[:key]
    render nothing: true
  end

  def new_email
    email = Email.find_or_create_by(email: params[:email][:email])
    if email.save
      email.update_attributes email_params
      EmailJob.new.async.perform UserMailer.new_email(email)
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  def new_vegas_email
    email = Email.find_or_create_by(email: params[:email][:email])
    if email.save
      email.update_attributes email_params
      EmailJob.new.async.perform UserMailer.new_vegas_email(email)
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  private

  def email_params
    params.require(:email).permit(:email, :zip, :comments, :vegas)
  end

end
