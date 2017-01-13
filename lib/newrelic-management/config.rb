# Encoding: UTF-8
#
# Gem Name:: newrelic-management
# NewRelicManagement:: Config
#
# Copyright (C) 2017 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'newrelic-management/helpers/configuration'
require 'pathname'

module NewRelicManagement
  # => This is the Configuration module.
  module Config
    module_function

    extend Configuration

    # => Gem Root Directory
    define_setting :root, Pathname.new(File.expand_path('../../../', __FILE__))

    # => My Name
    define_setting :author, 'Brian Dwyer - Intelligent Digital Services'

    # => Application Environment
    define_setting :environment, :production

    # => Config File
    define_setting :config_file, File.join(root, 'config', 'config.json')

    # => NewRelic API Key
    define_setting :nr_api_key, nil

    # => Daemonization
    define_setting :daemonize, false

    # => Silence Notifications
    define_setting :silent, false

    #
    # => Alert Management
    #

    # => Array of Alerts to Manage
    define_setting :alerts, []

    # => How often to run when Daemonized
    define_setting :alert_management_interval, '1m'

    # => Find entities matching any tag, instead of all tags
    define_setting :alert_match_any, false

    #
    # => Stale Server Management
    #

    # => Enable Stale Server Cleanup
    define_setting :cleanup, false

    # => Set a Time to keep Non-Reporting Servers
    define_setting :cleanup_age, nil

    # => How often to run when Daemonized
    define_setting :cleanup_interval, '1m'

    #
    # => Transient Configuration
    #
    define_setting :transient, {}

    #
    # => Facilitate Dynamic Addition of Configuration Values
    #
    # => @return [class_variable]
    #
    def add(config = {})
      config.each do |key, value|
        define_setting key.to_sym, value
      end
    end

    #
    # => Facilitate Dynamic Removal of Configuration Values
    #
    # => @return nil
    #
    def clear(config)
      Array(config).each do |setting|
        delete_setting setting
      end
    end

    #
    # => List the Configurable Keys as a Hash
    #
    # @return [Hash]
    #
    def options
      map = Config.class_variables.map do |key|
        [key.to_s.tr('@', '').to_sym, class_variable_get(:"#{key}")]
      end
      Hash[map]
    end
  end
end
