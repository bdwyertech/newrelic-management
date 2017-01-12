# Encoding: UTF-8
#
# Gem Name:: newrelic-management
# NewRelicManagement:: Notifier
#
# Copyright (C) 2017 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'terminal-notifier'
require 'os'

module NewRelicManagement
  # => Notification Methods
  module Notifier
    module_function

    def terminal_notification(message)
      puts message
    end

    def osx_notification(message, subtitle, title)
      TerminalNotifier.notify(message, title: title, subtitle: subtitle)
    end

    def msg(message, subtitle = message, title = 'NewRelic Management')
      # => Stdout Messages
      terminal_notification(message)

      return if Config.silent

      # => Pretty GUI Messages
      osx_notification(message, subtitle, title) if OS.x?
    end
  end
end
