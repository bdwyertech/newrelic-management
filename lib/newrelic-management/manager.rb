# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: newrelic-management
# NewRelicManagement:: Manager
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'json'

module NewRelicManagement
  # => Manager Methods
  module Manager
    module_function

    ######################
    # =>    Alerts    <= #
    ######################

    # => Manage Alerts
    def manage_alerts_fromfile
      Util.parse_json_config(Config.config_file, false)['manage']['alerts'].each do |alert|
        # => Set the Filtering Policy
        Config.alerts[:match_any] = alert['match_any'] ? true : false

        # => Manage the Alerts
        manage_alert(alert['name'], alert['labels'], alert['exclude'])
      end
    end

    def test_manage_alert
      manage_alert('RAM Utilization', ['Environment:Production'])
    end

    def manage_alert(alert, labels, exclude = []) # rubocop: disable AbcSize, MethodLength
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
      Array(entities).each do |entity|
        Client.alert_add_entity(entity, condition_id, type)
      end
    end

    def delete_from_alert(entities, condition_id, type = 'Server')
      Array(entities).each do |entity|
        Client.alert_delete_entity(entity, condition_id, type)
      end
    end

    # => Find Matching Alert (Name or ID)
    def find_alert(alert)
      id = Integer(alert) rescue nil # rubocop: disable RescueModifier
      Client.alert_policies.find do |policy|
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
      Client.alert_policies
    end

    # => List All Alert Conditions for an Alert Policy
    def list_alert_conditions(policy_id)
      Client.alert_conditions(policy_id)
    end

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

    #######################
    # =>    Servers    <= #
    #######################

    def list_servers
      Client.servers.sort_by { |hsh| hsh['last_reported_at'] }.collect do |server|
        {
          name: server['name'],
          last_reported_at: server['last_reported_at']
        }
      end
    end

    ######################
    # =>    Labels    <= #
    ######################

    def list_labels
      NewRelicManagement::Client.labels
    end

    # => Find Servers Matching a Label
    # => Example: find_labeled(['Role:API', 'Environment:Production'])
    def find_labeled(labels, match_any = Config.alerts[:match_any]) # rubocop: disable AbcSize, MethodLength
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
