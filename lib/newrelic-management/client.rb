# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: newrelic-management
# NewRelicManagement:: Client
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'rubygems'
require 'bundler/setup'
require 'faraday'
require 'faraday_middleware'
require 'newrelic-management/version'
require 'uri'

module NewRelicManagement
  # => NewRelic Manager Client
  module Client
    module_function

    # => Build the HTTP Connection
    def nr_api
      # => Build the Faraday Connection
      @conn ||= Faraday::Connection.new('https://api.newrelic.com', conn_opts) do |client|
        client.use Faraday::Response::RaiseError
        client.use FaradayMiddleware::EncodeJson
        client.use FaradayMiddleware::ParseJson, content_type: /\bjson$/
        client.response :logger if Config.environment.to_s.casecmp('development').zero? # => Log Requests to STDOUT
        client.adapter Faraday.default_adapter #:net_http_persistent
      end
    end

    def conn_opts
      {
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'X-api-key' => Config.nr_api_key
        },
        # => ssl: ssl_options
      }
    end

    #
    # => Alerts
    #

    # => List Alert Policies
    def alert_policies
      nr_api.get(url('alerts_policies')).body['policies']
    rescue NoMethodError
      []
    end

    # => List Alert Conditions
    def alert_conditions(policy)
      nr_api.get(url('alerts_conditions'), policy_id: policy).body
    end

    # => Add an Entitity to an Existing Alert Policy
    def alert_add_entity(entity_id, condition_id, entity_type = 'Server')
      nr_api.put do |req|
        req.url url('alerts_entity_conditions', entity_id)
        req.params['entity_type'] = entity_type
        req.params['condition_id'] = condition_id
      end
    end

    # => Add an Entitity to an Existing Alert Policy
    def alert_delete_entity(entity_id, condition_id, entity_type = 'Server')
      nr_api.delete do |req|
        req.url url('alerts_entity_conditions', entity_id)
        req.params['entity_type'] = entity_type
        req.params['condition_id'] = condition_id
      end
    end

    # => List the Labels
    def labels
      nr_api.get(url('labels')).body['labels']
    rescue NoMethodError
      []
    end

    #
    # => Servers
    #

    # => List the Servers Reporting to NewRelic
    def servers
      nr_api.get(url('servers')).body['servers']
    rescue NoMethodError
      []
    end

    # => Get Info for Specific Server
    def get_server(server)
      srv = get_server_id(server)
      srv ? srv : get_server_name(server)
    end

    # => Get a Server based on ID
    def get_server_id(server_id)
      return nil unless server_id =~ /^[0-9]+$/
      ret = nr_api.get(url('servers', server_id)).body
      ret['server']
    rescue Faraday::ResourceNotFound, NoMethodError
      nil
    end

    # => Get a Server based on Name
    def get_server_name(server, exact = true)
      ret = nr_api.get(url('servers'), 'filter[name]' => server).body
      return ret['servers'] unless exact
      ret['servers'].find { |x| x['name'].casecmp(server).zero? }
    rescue NoMethodError
      nil
    end

    # => List the Servers with a Label
    def get_servers_labeled(labels)
      label_query = Array(labels).reject { |x| !x.include?(':') }.join(';')
      return [] unless label_query
      nr_api.get(url('servers'), 'filter[labels]' => label_query).body
    end

    # => Delete a Server from NewRelic
    def delete_server(server_id)
      nr_api.delete(url('servers', server_id)).body
    end

    def url(*args)
      '/v2/' + args.map { |a| URI.encode_www_form_component a.to_s }.join('/') + '.json'
    end
    private :url
  end
end
