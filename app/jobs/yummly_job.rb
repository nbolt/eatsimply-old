class YummlyJob
  include SuckerPunch::Job

  def perform(yummly_id, email, firebase_key, nums, reset_next)
    ActiveRecord::Base.connection_pool.with_connection do
      email = Email.where(email: email)[0]
      recipe = Recipe.where(yummly_id: yummly_id)[0]
      if recipe
        rsp = {
          success: true,
          message: nil,
          recipe: recipe,
          nums: nums
        }
      else
        rsp = Recipe.import(yummly_id)
        if rsp[:recipe]
          rsp[:recipe].update_attribute :added_by, email.then(:id)
          rsp = {
            success: true,
            message: nil,
            recipe: rsp[:recipe],
            nums: nums
          }
        else
          rsp = {
            success: false,
            message: rsp[:message],
            recipe: nil,
            nums: nums
          }
        end
      end
      FirebaseJob.new.perform firebase_key, {
        event: 'new-recipe',
        success: rsp[:success],
        recipe: rsp[:recipe],
        message: rsp[:message],
        nums: nums,
        clear_next: false,
        reset_next: reset_next
      }
    end
  end
end