require "test_helper"

describe Recipe do
  fixtures :courses
  fixtures :cuisines

  let(:params) { YAML.load(File.read("#{Rails.root}/test/data/recipe_params.yml")) }
  let(:main) { courses(:main) }
  let(:asian) { cuisines(:asian) }

  it 'successfully imports' do
    rsp = nil
    VCR.use_cassette('test') { rsp = Recipe.import params['id'] }
    rsp[:success].must_equal true
    rsp[:recipe].courses.must_include main
    rsp[:recipe].cuisines.must_include asian
    rsp[:recipe].recipe_images[0].must_be_instance_of RecipeImage
    Nutrient.all.each do |nutrient|
      data = params['nutritionEstimates'].find {|n| n['attribute'] == nutrient.attr}
      if data
        serving = rsp[:recipe].nutrient_profile.servings.find {|s| s.nutrient_id == nutrient.id}
        serving.value.must_equal data['value']
      end
    end
  end

end