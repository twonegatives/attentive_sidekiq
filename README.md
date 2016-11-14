# Attentive Sidekiq

[![Gem Version](https://badge.fury.io/rb/attentive_sidekiq.svg)](https://badge.fury.io/rb/attentive_sidekiq)
[![Code Climate](https://codeclimate.com/github/twonegatives/attentive_sidekiq/badges/gpa.svg)](https://codeclimate.com/github/twonegatives/attentive_sidekiq)
[![CircleCI](https://circleci.com/gh/twonegatives/attentive_sidekiq.svg?style=shield)](https://circleci.com/gh/twonegatives/attentive_sidekiq)


### Motivation
It's common to face the issues with sidekiq killing jobs in the middle of processing and not putting them back to redis.
This issue leads to jobs losage, which essentualy means probable loss of critical user data.
Sidekiq's author, Mike Perham, suggests purchasing Sidekiq Pro which uses another fetch mechanism providing you with a confidence that ensures jobs persist in redis at any time.
However, it is reported by some users to still to cause the same issue.


### About
Attentive Sidekiq is a sidekiq plugin which monitors the jobs being started but not finished (successfully or badly).
It saves started jobs info into redis hash and checks whether any job stays there for too long (without being processed or deleted due to job success/failure).

### Installation
Add this line to your application's Gemfile:
    
    gem 'attentive_sidekiq'

And then execute:

    $ bundle

### Usage
Configure your middleware chains, lookup Middleware usage on Sidekiq wiki for more info.

    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add AttentiveSidekiq::Middleware::Server::Attentionist
      end
    end

After that you can use your jobs as usual.

### Sidekiq Web integration
Attentive Sidekiq provides an extension to the Sidekiq web interface that adds a Disappeared Jobs page.
To use it, head to your sidekiq dashboard and click the link at the tabs section.
