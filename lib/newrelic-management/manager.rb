# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: newrelic-management
# NewRelicManagement:: Manager
#
# Copyright (C) 2017 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'chronic_duration'
require 'json'
require 'newrelic-management/client'
require 'newrelic-management/config'
require 'newrelic-management/notifier'

module NewRelicManagement
  # => Manager Methods
  module Manager
    module_function

    ######################
    # =>    Alerts    <= #
    ######################

    # => Manage Alerts
    def manage_alerts
      Array(Config.alerts).each do |alert|
        # => Set the Filtering Policy
        Config.transient[:alert_match_any] = alert[:match_any] ? true : false

        # => Manage the Alerts
        manage_alert(alert[:name], alert[:labels], alert[:exclude])
      end
    end

    def manage_alert(alert, labels, exclude = []) # rubocop: disable AbcSize
      conditions = find_alert_conditions(alert) || return
      tagged_entities = find_labeled(labels)
      excluded = find_excluded(exclude)

      conditions.each do |condition|
        next unless condition['type'] == 'servers_metric'
        existing_entities = condition['entities']

        to_add = tagged_entities.map(&:to_i) - existing_entities.map(&:to_i) - excluded
        to_delete = excluded & existing_entities.map(&:to_i)

        add_to_alert(to_add, condition['id'])
        delete_from_alert(to_delete, condition['id'])
      end
    end

    def add_to_alert(entities, condition_id, type = 'Server')
      return if entities.empty?
      Notifier.add_servers(entities)
      Array(entities).each do |entity|
        Client.alert_add_entity(entity, condition_id, type)
      end
    end

    def delete_from_alert(entities, condition_id, type = 'Server')
      return if entities.empty?
      Notifier.remove_servers(entities)
      Array(entities).each do |entity|
        Client.alert_delete_entity(entity, condition_id, type)
      end
    end

    # => Find Matching Alert (Name or ID)
    def find_alert(alert)
      id = Integer(alert) rescue nil # rubocop: disable RescueModifier
      list_alerts.find do |policy|
        return policy if id && policy['id'] == id
        policy['name'].casecmp(alert).zero?
      end
    end

    # => Find Alert Conditions for a Matching Alert Policy
    def find_alert_conditions(alert)
      alert = find_alert(alert)
      list_alert_conditions(alert['id'])['conditions'] if alert
    end

    # => Simply List Alerts
    def list_alerts
      Util.cachier('list_alerts') { Client.alert_policies }
    end

    # => List All Alert Conditions for an Alert Policy
    def list_alert_conditions(policy_id)
      Util.cachier("alert_conditions_#{policy_id}") { Client.alert_conditions(policy_id) }
    end

    #######################
    # =>    Servers    <= #
    #######################

    # => Servers with the oldest `last_reported_at` will be at the top
    def list_servers
      Util.cachier('list_servers') do
        Client.servers.sort_by { |hsh| hsh['last_reported_at'] }.collect do |server|
          {
            name: server['name'],
            last_reported_at: server['last_reported_at'],
            id: server['id'],
            reporting: server['reporting']
          }
        end
      end
    end

    def list_nonreporting_servers
      list_servers.reject { |server| server[:reporting] }
    end

    # => Remove Non-Reporting Servers
    def remove_nonreporting_servers(keeptime = nil)
      list_nonreporting_servers.each do |server|
        next if keeptime && Time.parse(server[:last_reported_at]) >= Time.now - ChronicDuration.parse(keeptime)
        Notifier.msg(server[:name], 'Removing Stale, Non-Reporting Server')
        Client.delete_server(server[:id])
      end
    end

    # => Find Servers which should be excluded from Management
    def find_excluded(excluded)
      result = []
      Array(excluded).each do |exclude|
        if exclude.include?(':')
          find_labeled(exclude).each { |x| result << x }
          next
        end
        res = Client.get_server(exclude)
        result << res['id'] if res
      end
      result
    end

    ######################
    # =>    Labels    <= #
    ######################

    def list_labels
      Util.cachier('list_labels') { Client.labels }
    end

    # => Find Servers Matching a Label
    # => Example: find_labeled(['Role:API', 'Environment:Production'])
    def find_labeled(labels, match_any = Config.transient[:alert_match_any]) # rubocop: disable AbcSize
      list = list_labels
      labeled = []
      Array(labels).select do |lbl|
        list.select { |x| x['key'].casecmp(lbl).zero? }.each do |mtch|
          labeled.push(Array(mtch['links']['servers']))
        end
      end

      unless match_any
        # => Array(labeled) should contain one array per label
        # => # => If it does not, it means the label is missing or misspelled
        return [] unless labeled.count == Array(labels).count

        # => Return Only those matching All Labels
        return Util.common_array(labeled)
      end
      labeled.flatten.uniq
    end
  end
end
