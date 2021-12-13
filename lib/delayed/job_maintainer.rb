class Delayed::JobMaintainer
  CRON_JOBS_PATH = 'app/jobs/cron/**/*.rb'.freeze
  RB_EXTENSION_REGEXP = /\.rb\z/.freeze

  def self.update_jobs
    delete_jobs_with_no_job_class
    job_classes.each do |klass|
      next if klass.cron.blank?
      if (existing = cron_jobs.where("handler LIKE ?", "%#{klass}%").first)
        update_existing(existing, klass)
      else # create new
        klass.perform_later
      end
    end
  end

  def self.workers
    @workers ||= `ps aux | grep delayed`.split("\n").collect{|p| p unless p.include?('grep')}.compact
  end

  def self.chrome_processes
    @chrome_processes = `ps aux | grep chrome`.split("\n").collect{|p| p unless p.include?('grep')}.compact
  end

  # private

  # Jobs that have been deleted or renamed
  def self.delete_jobs_with_no_job_class
    cron_jobs.each do |job|
      job_class = Psych.load(job.handler).job_data['job_class']
      next if job_classes.collect(&:to_s).include?(job_class)
      job.destroy
    end
  end

  def self.update_existing(existing, klass)
    queue = klass.new.queue_name
    priority = Delayed::Worker.queue_attributes.dig(queue, 'priority') || 0
    existing.queue = queue
    existing.priority = priority
    existing.cron = klass.cron
    existing.save!
  end

  def self.cron_jobs
    Delayed::Job.where.not(cron: nil)
  end

  def self.job_classes
    Dir[CRON_JOBS_PATH].map do |path|
      path.gsub(RB_EXTENSION_REGEXP, '').split('/').drop(CRON_JOBS_PATH.count('/') - 1).map(&:camelcase).join('::').constantize
    end
  end
end
