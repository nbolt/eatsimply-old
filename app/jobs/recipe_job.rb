class RecipeJob
  include SuckerPunch::Job

  def perform(opts)
  	Recipe.meals(opts) do |rsp, nums, clear_next|
      FirebaseJob.new.perform "#{opts[:key]}", { event: 'new-recipe', recipe: rsp[:recipe], nums: nums, clear_next: clear_next }
    end
  end
end