# Encoding: UTF-8
#
# Gem Name:: newrelic-management
# NewRelicManagement:: Controller
#
# Copyright (C) 2017 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'rufus-scheduler'

module NewRelicManagement
  # => Utility Methods
  module Controller
    module_function

    # => Daemonization for Periodic Management
    def daemon # rubocop: disable AbcSize, MethodLength
      scheduler = Rufus::Scheduler.new
      Notifier.msg('Daemonizing Process')

      # => Alerts Management
      alerts_interval = Config.manage[:alert_management_interval]
      scheduler.every alerts_interval do
        Manager.manage_alerts
      end

      # => Cleanup Stale Servers
      if Config.manage[:cleanup]
        cleanup_interval = Config.manage[:cleanup_management_interval]
        cleanup_age = Config.manage[:cleanup_age]

        scheduler.every cleanup_interval do
          Manager.remove_nonreporting_servers(cleanup_age)
        end
      end

      # => Join the Current Thread to the Scheduler Thread
      scheduler.join
    end

    # => Run the Application
    def run
      daemon if Config.daemonize

      # => Manage Alerts
      Manager.manage_alerts

      # => Manage
      Manager.remove_nonreporting_servers(Config.manage[:cleanup_age])
    end
  end
end
