class DataController < ApplicationController

  def ingredients
    render json: Ingredient.search(params[:term]).as_json
  end

  def cuisines
    render json: Cuisine.search(params[:term]).as_json
  end

  def recipes
    days = [{name:'Monday'}, {name:'Tuesday'}, {name:'Wednesday'}, {name:'Thursday'}, {name:'Friday'}, {name:'Saturday'}, {name:'Sunday'}]
    recipes = Recipe.all.shuffle
    7.times do |d|
      days[d][:meals] = []
      3.times do |m|
        puts (d*6+(m*2)..d*6+(m*2+1))
        days[d][:meals][m] = {}
        days[d][:meals][m][:recipes] = recipes[d*6+(m*2)..d*6+(m*2+1)]
      end
    end
    render json: days.as_json
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
