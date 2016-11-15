module AttentiveSidekiq
  module Web
    VIEW_PATH = File.expand_path("../web/views", __FILE__)

    def self.registered(app)
      app.get('/disappeared-jobs') do
        @suspicious_jobs  = AttentiveSidekiq::DisappearedSet.new.jobs
        erb File.read(File.join(VIEW_PATH, 'disappeared-list.erb'))
      end	
    end
  end
end

Sidekiq::Web.register AttentiveSidekiq::Web
Sidekiq::Web.locales << File.expand_path(File.dirname(__FILE__) + "/web/locales")
Sidekiq::Web.tabs['disappeared_jobs'] = 'disappeared-jobs'
