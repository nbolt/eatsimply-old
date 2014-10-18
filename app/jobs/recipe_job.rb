class RecipeJob
  include SuckerPunch::Job

  def perform(opts)
  	Recipe.meals(opts) do |rsp, nums, clear_next|
      FirebaseJob.new.perform "#{opts[:key]}", {
        event: 'new-recipe',
        success: rsp[:success],
        recipe: rsp[:recipe],
        message: rsp[:message],
        nums: nums,
        clear_next: clear_next
      }
    end
  end
end