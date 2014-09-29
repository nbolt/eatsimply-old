class RecipeJob
  include SuckerPunch::Job

  def perform(key)
  	Recipe.meals(7,3,DvProfile.find(3)) do |rsp, nums|
      Pusher.trigger("recipes-#{key}", 'new-recipe', { recipe: rsp[:recipe], nums: nums })
      Pusher.trigger('recipes', 'close', {}) if nums[0] == 6 && nums[1] == 2
    end
  end
end