class ImportJob
  include SuckerPunch::Job

  def perform(id, opts={})
    ActiveRecord::Base.connection_pool.with_connection do
      Recipe.import id, opts
    end
  end
end