# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: newrelic-management
# NewRelicManagement:: CLI
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'mixlib/cli'
require 'newrelic-management/client'
require 'newrelic-management/config'
require 'newrelic-management/manager'
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
    end

    # => Launch the Application
    def run(argv = ARGV) # rubocop: disable AbcSize
      # => Parse CLI Configuration
      cli = Options.new
      cli.parse_options(argv)

      # => Parse JSON Config File (If Specified and Exists)
      json_config = Util.parse_json_config(cli.config[:config_file] || Config.config_file)

      # => Grab the Default Values
      default = Config.options

      # => Merge Configuration (CLI Wins)
      config = [default, json_config, cli.config].compact.reduce(:merge)

      # => Apply Configuration
      Config.setup do |cfg|
        cfg.config_file = config[:config_file]
        cfg.nr_api_key = config[:nr_api_key]
        cfg.manage = config[:manage]
      end

      # => Launch the Plugin
      # => NewRelicManagement::Run.setup_and_run
    end
  end
end
