require "test_helper"

describe Admin::RecipeController do
  fixtures :courses
  fixtures :cuisines
  fixtures :diets
  fixtures :units
  fixtures :recipes

  let(:create_params) { YAML.load(File.read("#{Rails.root}/test/data/recipe_params.yml")) }
  let(:update_params) { YAML.load(File.read("#{Rails.root}/test/data/update_params.yml")) }
  let(:main) { courses(:main) }
  let(:asian) { cuisines(:asian) }
  let(:vegan) { diets(:vegan) }
  let(:vegetarian) { diets(:vegetarian) }
  let(:pescetarian) { diets(:pescetarian) }

  it 'successfully creates' do
    Recipe.destroy_all
    IngredientLink.destroy_all

    VCR.use_cassette('admin_recipe_controller_test') do
      post :create, create_params
    end

    rsp = JSON.parse @response.body
    rsp['success'].must_equal true

    recipe = Recipe.find rsp['id']

    recipe.courses.must_include main
    recipe.cuisines.must_include asian
    recipe.diets.must_include vegan
    recipe.diets.must_include vegetarian
    recipe.diets.must_include pescetarian
    recipe.recipe_images[0].must_be_instance_of RecipeImage

    IngredientLink.all.each do |link|
      param_data = create_params['ingredients'].find {|i| (i['name'] || i['profile']['text']) == link.ingredient.name}
      link.display_amount.must_equal param_data['amount'].to_frac * param_data['unit']['multiplier']
      link.amount.must_equal param_data['amount'].to_frac
    end
    
    Nutrient.all.each do |nutrient|
      serving = recipe.nutrient_profile.servings.find {|s| s.nutrient_id == nutrient.id}
      case nutrient.id
      when 1 then serving.value.must_equal 138.82
      when 2 then serving.value.must_equal 1196.33
      when 3 then serving.value.must_equal 4.79
      when 4 then serving.value.must_equal 902.78
      when 5 then serving.value.must_equal 19.43
      when 7 then serving.value.must_equal 0.0
      when 8 then serving.value.must_equal 459.61
      when 9 then serving.value.must_equal 164.145
      when 10 then serving.value.must_equal 18.41
      when 11 then serving.value.must_equal 11.24
      when 12 then serving.value.must_equal 21359.74
      when 13 then serving.value.must_equal 17.925
      when 14 then serving.value.must_equal 43.6
      when 15 then serving.value.must_equal 6.83
      end
    end
  end

  it 'successfully updates' do
    VCR.use_cassette('admin_recipe_controller_test') do
      post :update, update_params
    end

    rsp = JSON.parse @response.body
    rsp['success'].must_equal true
    recipe = Recipe.find rsp['id']

    recipe.courses.must_include main
    recipe.cuisines.must_include asian
    recipe.diets.must_include vegan
    recipe.diets.must_include vegetarian
    recipe.diets.must_include pescetarian
    recipe.recipe_images[0].must_be_instance_of RecipeImage
    
    Nutrient.all.each do |nutrient|
      serving = recipe.nutrient_profile.servings.find {|s| s.nutrient_id == nutrient.id}
      case nutrient.id
      when 1 then serving.value.must_equal 138.82
      when 2 then serving.value.must_equal 1196.33
      when 3 then serving.value.must_equal 4.79
      when 4 then serving.value.must_equal 902.78
      when 5 then serving.value.must_equal 19.43
      when 7 then serving.value.must_equal 0.0
      when 8 then serving.value.must_equal 459.61
      when 9 then serving.value.must_equal 164.145
      when 10 then serving.value.must_equal 18.41
      when 11 then serving.value.must_equal 11.24
      when 12 then serving.value.must_equal 21359.74
      when 13 then serving.value.must_equal 17.925
      when 14 then serving.value.must_equal 43.6
      when 15 then serving.value.must_equal 6.83
      end
    end
  end

end