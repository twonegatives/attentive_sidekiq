module AttentiveSidekiq
  module Web
    VIEW_PATH = File.expand_path("../web/views", __FILE__)

  	def self.registered(app)
  	  app.helpers do
  		  def jobs_not_finished
  		    jsoned_jobs = Sidekiq.redis{|conn| conn.hvals(AttentiveSidekiq::Middleware::REDIS_KEY)}
      	  jsoned_jobs.map!{|i| JSON.parse(i)}
  	    end
      end

  	  app.get('/disappeared-jobs') do
        jobs_active_now   = Set.new(Sidekiq::Workers.new.to_a.map{|i| i[2]["payload"]["jid"]})
      	@suspicious_jobs  = jobs_not_finished.delete_if{|i| jobs_active_now.include?(i["jid"])}
      	erb File.read(File.join(VIEW_PATH, 'disappeared-list.erb'))
  	  end	
  	end
  end
end

Sidekiq::Web.register AttentiveSidekiq::Web
Sidekiq::Web.locales << File.expand_path(File.dirname(__FILE__) + "/web/locales")
Sidekiq::Web.tabs['disappeared_jobs'] = 'disappeared-jobs'