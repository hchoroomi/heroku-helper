def environment(env, &block)
  HerokuHelper::DeploymentConfiguration.current_environment = env
  HerokuHelper::DeploymentConfiguration.configuration[env]  = {}
  block.call
end

def set(name, value)
  HerokuHelper::DeploymentConfiguration.
    configuration[HerokuHelper::DeploymentConfiguration.current_environment][name] = value
end

def hook(stage, command, &block)
  configuration = HerokuHelper::DeploymentConfiguration.configuration[HerokuHelper::DeploymentConfiguration.current_environment]
  configuration[:hooks]               ||= {}
  configuration[:hooks][command]      ||= {}
  configuration[:hooks][command][stage] = block
end

module HerokuHelper
  class DeploymentConfiguration

    class << self
      attr_accessor :current_environment
      attr_accessor :configuration
    end

    def self.configure(conf_file)
      self.configuration ||= {}
      require conf_file
    end

    def self.configuration_format
      <<-FORMAT
# heroku_deploy.rb
environment :production do
  set :app_name, 'heroku-application-name'
  set :domain,   'example.com'
  set :contributors, %w(dev1@example.com dev2@example.com)
  set :environment_variables, {
    'REDIS_URL' => 'redis://localhost:6379/0'
  }
  set :addons, [
    'custom_domains',
    'gmail_smtp email=foo@bar.com password=sekret'
  ]

  hook :before, :share do
    puts 'hello before share'
  end

  hook :after, :deploy do
    puts 'hello after deploy'
  end
end
      FORMAT
    end
    
  end
end