class RecipeJob
  include SuckerPunch::Job

  def perform(opts)
  	Recipe.meals(opts) do |rsp, nums|
      Pusher.trigger("recipes-#{opts[:key]}", 'new-recipe', { recipe: rsp[:recipe], nums: nums })
      Pusher.trigger('recipes', 'close', {}) if nums[0] == 6 && nums[1] == 2
    end
  end
end