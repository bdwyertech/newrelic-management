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

    # => Management Configuration
    define_setting :manage,
                   alerts: [],
                   alert_management_interval: '1m',
                   cleanup: false,
                   cleanup_age: nil,
                   cleanup_management_interval: '1m'

    # => Alert Management Configuration
    define_setting :alerts,
                   # => Find entities matching any tag, instead of all tags
                   match_any: false

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
