require 'optparse'

module HerokuHelper
  class CLI
    def self.execute(stdout, arguments=[])
      options = {
        :env     => 'production',
        :command => 'deploy'
      }
      available_commands = %w(deploy share restart set_vars add_addons)
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Heroku deployment helper

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("-e", "--env=ENV", String,
                "Set environment. Default is production.") { |arg| options[:env] = arg }
        opts.on("-c", "--command=COMMAND", String,
                "Heroku command to run. Default is deploy.",
                "Available commands: #{available_commands.join(', ')}") { |arg| options[:command] = arg }
        opts.on("-f", "--format",
                "Shows deploy.yml file format.") { stdout.puts DeploymentConfiguration.configuration_format; exit }
        opts.on("-v", "--version",
                "Show the #{File.basename($0)} version number and quit.") { stdout.puts "#{File.basename($0)} #{HerokuHelper::VERSION}"; exit }
        opts.on("-h", "--help", "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end

      raise "Command '#{options[:command]}' not found" unless available_commands.include?(options[:command])
      Heroku.new(options[:env]).run(options[:command])
    end
  end
end