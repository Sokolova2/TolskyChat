class ArchiveCleanupJob
  include Sidekiq::Job

  def perform(*args)
    time = 3.months.ago

    Room.where("deleted_at <= ?", time).delete_all
  end
end
