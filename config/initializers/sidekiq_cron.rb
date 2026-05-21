if defined?(Sidekiq) && Sidekiq.server?
  schedule_file = Rails.root.join('config/sidekiq.yml')

  if File.exist?(schedule_file)
    config = YAML.load_file(schedule_file)
    cron_jobs = config[:cron] || config['cron'] || {}
    Sidekiq::Cron::Job.load_from_hash!(cron_jobs) if cron_jobs.any?
  end
end