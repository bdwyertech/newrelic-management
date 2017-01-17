# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: newrelic-management
# NewRelicManagement:: Notifier
#
# Copyright (C) 2017 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'newrelic-management/config'
require 'newrelic-management/util'
require 'os'
require 'terminal-notifier'

module NewRelicManagement
  # => Notification Methods
  module Notifier
    module_function

    # => Primary Notification Message Controller
    def msg(message, subtitle = message, title = 'NewRelic Management')
      # => Stdout Messages
      terminal_notification(message, subtitle)

      return if Config.silent

      # => Pretty GUI Messages
      osx_notification(message, subtitle, title) if OS.x?
    end

    # => Console Messages
    def terminal_notification(message, subtitle = nil)
      message = "#{subtitle}: #{message}" if subtitle && (message != subtitle)
      puts message
    end

    # => OS X Cocoa Messages
    def osx_notification(message, subtitle, title)
      TerminalNotifier.notify(message, title: title, subtitle: subtitle)
    end

    # => Application-Specific Messages
    def add_servers(servers)
      servers(servers, 'Adding Server(s) to Alert')
    end

    def remove_servers(servers)
      servers(servers, 'Removing Server(s) from Alert')
    end

    def remove_stale(servers)
      servers(servers, 'Removing Server(s) from Alert')
    end

    private def servers(servers, subtitle)
      list = Manager.list_servers
      msg = list.select { |svr| Array(servers).include?(svr[:id]) }.map { |x| x[:name] }

      msg(msg, subtitle)
    end
  end
end
