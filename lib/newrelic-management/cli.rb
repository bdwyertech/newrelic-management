# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: newrelic-management
# NewRelicManagement:: CLI
#
# Copyright (C) 2017 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'deep_merge'
require 'mixlib/cli'
require 'newrelic-management/config'
require 'newrelic-management/controller'
require 'newrelic-management/util'

module NewRelicManagement
  #
  # => NewRelic Launcher
  #
  module CLI
    module_function

    #
    # => Options Parser
    #
    class Options
      # => Mix-In the CLI Option Parser
      include Mixlib::CLI

      option :config_file,
             short: '-c CONFIG',
             long: '--cfg-file CONFIG',
             description: "Configuration File (Default: #{Config.config_file})"

      option :cleanup,
             short: '-o',
             long: '--cleanup',
             description: 'Cleanup Non-Reporting Servers',
             boolean: true

      option :cleanup_age,
             short: '-a AGE',
             long: '--cleanup-age AGE',
             description: 'Cleanup Non-Reporting Servers older than an interval of time'

      option :daemonize,
             short: '-d',
             long: '--daemonize',
             description: 'Flag for running in Daemonized mode',
             boolean: true

      option :silent,
             short: '-s',
             long: '--silent',
             description: 'Suppress all notification messages',
             boolean: true

      option :environment,
             short: '-e ENV',
             long: '--env ENV',
             description: 'Sets the environment for newrelic-management to execute under. Use "development" for more logging.',
             proc: proc { |env| env.to_sym }
    end

    # => Configure the CLI
    def configure(argv = ARGV)
      # => Parse CLI Configuration
      cli = Options.new
      cli.parse_options(argv)

      # => Parse JSON Config File (If Specified and Exists)
      json_config = Util.parse_json(cli.config[:config_file] || Config.config_file)

      # => Grab the Default Values
      default = Config.options

      # => Merge Configuration (CLI Wins)
      config = [json_config, cli.config].compact.reduce(:merge).deep_merge(default)

      # => Apply Configuration
      config.each { |k, v| Config.send("#{k}=", v) }
    end

    # => Launch the Application
    def run(argv = ARGV)
      # => Parse the Params
      configure(argv)

      # => Launch the Controller
      Controller.run
    end
  end
end
