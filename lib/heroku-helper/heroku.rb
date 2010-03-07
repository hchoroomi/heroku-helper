module HerokuHelper
  class Heroku

    attr_accessor :environment

    def initialize(env)
      @environment = env
      load_configuration
      puts "#{application_name} - #{environment}\n"      
    end

    def deploy
      remote = cmd("git remote add git-remote-for-#{application_name} git@heroku.com:#{application_name}.git 2>&1")
      if remote !~ /remote git-remote-for-#{application_name} already exists/
        cmd("git push git-remote-for-#{application_name} master")
      else
        cmd("git push -f git-remote-for-#{application_name}")
      end
      cmd("heroku rake db:migrate --app #{application_name}")
    end

    def share
      contributors.each do |dev|
        cmd 'heroku sharing:add', dev, '--app', application_name
      end
    end

    def restart
      cmd 'heroku restart', '--app', application_name
    end

    def set_vars
      environment_variables.each do |key, value|
        cmd 'heroku config:add', "#{key}=#{value}", '--app', application_name
      end
    end

    def add_addons
      addons.each do |addon|
        cmd 'heroku addons:add', addon, '--app', application_name
      end
    end

    private

    def load_configuration
      deployment_configuration = 'deploy.yml'
      if File.exist?(deployment_configuration)
        @config = YAML.load_file(deployment_configuration)
      else
        puts "No deployment configuration found (looking for: #{deployment_configuration})"
        puts "Run #{File.basename($0)} -f for more information."
        exit(1)
      end
    end

    def self.configuration_format
      <<-FORMAT
production:
  app_name: sample-app
  domain: sample-app.com
  contributors:
    - dev1@production.com
    - dev2@production.com
  environment_variables:
    AWS: aws_cred
    REDIS_URL: redis_url
  addons:
    - custom_domains
    - gmail_smtp email=foo@bar.com password=sekret
      FORMAT
    end

    # TODO rename to prevent confusion w/ heroku config
    def config(key)
      raise 'Cannot find specified key in the YAML file' unless @config[environment].has_key?(key)
      @config[environment][key]
    end

    def application_name
      config('app_name')
    end

    def contributors
      config('contributors')
    end

    def environment_variables
      config('environment_variables')
    end

    def addons
      config('addons')
    end

    def cmd(*command)
      command = command.join(' ')
      puts "Executing: #{command}"
      `#{command}`
    end

  end
end