class RecipeJob
  include SuckerPunch::Job

  def perform(opts)
    ActiveRecord::Base.connection_pool.with_connection do
    	Recipe.meals(opts) do |rsp, nums, clear_next|
        FirebaseJob.new.perform "#{opts[:key]}", {
          event: 'new-recipe',
          success: rsp[:success],
          recipe: rsp[:recipe],
          message: rsp[:message],
          nums: nums,
          clear_next: clear_next,
          reset_next: opts[:reset_next]
        }
      end
    end
  end
end