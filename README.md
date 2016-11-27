Attentive Sidekiq
===========================

[![Gem Version](https://badge.fury.io/rb/attentive_sidekiq.svg)](https://badge.fury.io/rb/attentive_sidekiq)
[![Downloads](http://ruby-gem-downloads-badge.herokuapp.com/attentive_sidekiq?type=total&total_label=&color=brightgreen)](https://rubygems.org/gems/attentive_sidekiq)
[![Code Climate](https://codeclimate.com/github/twonegatives/attentive_sidekiq/badges/gpa.svg)](https://codeclimate.com/github/twonegatives/attentive_sidekiq)
[![CircleCI](https://circleci.com/gh/twonegatives/attentive_sidekiq.svg?style=shield)](https://circleci.com/gh/twonegatives/attentive_sidekiq)

Be aware of suddenly disappeared sidekiq jobs!

![shortsummary](https://cloud.githubusercontent.com/assets/1937799/20489411/fe726e82-b023-11e6-9528-7df519fec7dd.gif)

### About 
The case of disappearing sidekiq jobs was proved by [github issues](https://github.com/mperham/sidekiq/issues/1831), [stackoverflow questions](http://stackoverflow.com/questions/35555000/current-sidekiq-job-lost-when-deploying-to-heroku) and (sadly) personal experience. Attentive Sidekiq was made to protect your jobs and critical data from silent disappearing. In case there appears a job being started but not finished and not being processing at the moment, you will know this.

### Usage
Attentive Sidekiq provides you with a couple of useful API methods.

To get a hash containing all information about jobs marked as disappeared:
```ruby
AttentiveSidekiq::Disappeared.jobs
```

To get only JIDs of lost jobs:
```ruby
AttentiveSidekiq::Disappeared.job_ids
```

To place a disappeared job back into queue:
```ruby
AttentiveSidekiq::Disappeared.requeue(jid)
```

To remove a job from disappeared hash (e.g. after manual requeue):
```ruby
AttentiveSidekiq::Disappeared.remove(jid)
```

### Sidekiq Web integration
You may also watch info about disappeared jobs in a web UI.
Simply make sure you have Sidekiq UI enabled, then head right to the Disappeared Jobs tab in the navbar.
The Web UI uses the API exclusively: anything you can do in the UI can be scripted with the API.

![webui](https://cloud.githubusercontent.com/assets/1937799/20490807/a01216d0-b028-11e6-96b7-c23fd67bdf89.png)

### Pre-requirements and notes

- Attentive Sidekiq assumes you've got Sidekiq installed already.
- You should make sure sidekiq process is started in order for disappeared jobs updater to work properly.
- It was tested with Sidekiq version 4. Seamless functionality with lower sidekiq versions is not guaranteed.

### Installation

Add this line to your application's Gemfile:
    
    gem 'attentive_sidekiq'

And then execute:

    $ bundle

Configure your middleware chains, lookup [Middleware usage](https://github.com/mperham/sidekiq/wiki/Middleware) on Sidekiq wiki for more info.

```ruby
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add AttentiveSidekiq::Middleware::Server::Attentionist
  end
end
```

After that you can use your jobs as usual.

### Configuration

Specify desired configuration inside of `sidekiq.yml` file:

```YML
attentive:
  # Time in seconds between checks for disappeared jobs
  :execution_interval: 300  # default: 600
  # Time limit in seconds to perform disappeared jobs check
  :timeout_interval: 25     # default: 60
```

By default, Attentive Sidekiq uses `Sidekiq.logger` to log its work. You may change it in your initializer:

```ruby
AttentiveSidekiq.logger = Logger.new("log/attentive_sidekiq.log")
```

### Suggestions? Bugs?

If you've got a question, feature suggestion or found a bug please add an [issue on GitHub](https://github.com/twonegatives/attentive_sidekiq/issues) or fork the project and send a pull request.
