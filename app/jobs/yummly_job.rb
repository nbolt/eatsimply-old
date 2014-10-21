class YummlyJob
  include SuckerPunch::Job

  def perform(yummly_id, firebase_key, nums)
    recipe = Recipe.where(yummly_id: yummly_id)[0]
    recipe = Recipe.import(yummly_id)[:recipe] unless recipe
    rsp = {
      success: true,
      message: nil,
      recipe: recipe,
      nums: nums
    }
    FirebaseJob.new.perform firebase_key, {
      event: 'new-recipe',
      success: rsp[:success],
      recipe: rsp[:recipe],
      message: rsp[:message],
      nums: nums,
      clear_next: false
    }
  end
end