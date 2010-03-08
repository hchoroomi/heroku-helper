def environment(env, &block)
  HerokuHelper::DeploymentConfiguration.current_environment        = env
  HerokuHelper::DeploymentConfiguration.configuration[env]         = {}
  HerokuHelper::DeploymentConfiguration.configuration[env][:hooks] = {}
  block.call
end

def set(name, value)
  HerokuHelper::DeploymentConfiguration.
    configuration[HerokuHelper::DeploymentConfiguration.current_environment][name] = value
end

def hook(stage, command, &block)
  configuration = HerokuHelper::DeploymentConfiguration.configuration[HerokuHelper::DeploymentConfiguration.current_environment]
  configuration[:hooks][command]      ||= {}
  configuration[:hooks][command][stage] = block
end

def before(command, &block)
  hook(:before, command, &block)
end

def after(command, &block)
  hook(:after, command, &block)
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

  before :share do
    # run code before sharing
  end

  after :deploy do
    # run code after deploy
  end
end
      FORMAT
    end
    
  end
end
