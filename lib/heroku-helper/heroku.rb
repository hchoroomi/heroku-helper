module HerokuHelper
  class Heroku

    attr_accessor :environment

    def initialize(env)
      @environment = env.intern
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

    def run(command)
      command = command.intern
      run_before_hook(command)
      send(command)
      run_after_hook(command)
    end

    private

    def load_configuration
      deployment_configuration = 'heroku_deploy.rb'
      if File.exist?(deployment_configuration)
        DeploymentConfiguration.configure(deployment_configuration)
        @config = DeploymentConfiguration.configuration
      else
        puts "No deployment configuration found (looking for: #{deployment_configuration})"
        puts "Run #{File.basename($0)} -f for more information."
        exit(1)
      end
    end

    def config(key)
      key = key.intern
      raise 'Cannot find specified key in the deployment file' unless @config[environment].has_key?(key)
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

    def run_before_hook(command)
      run_hook :before, command
    end

    def run_after_hook(command)
      run_hook :after, command
    end

    def run_hook(stage, command)
      if config('hooks') && config('hooks')[command] && config('hooks')[command][stage]
        config('hooks')[command][stage].call
      end
    end

  end
end