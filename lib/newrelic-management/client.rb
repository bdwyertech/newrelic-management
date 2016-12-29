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
        client.response :logger if Config.environment.casecmp('development').zero? # => Log Requests to STDOUT
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

    # => List the Labels
    def labels
      nr_api.get(url('labels')).body['labels']
    rescue NoMethodError
      []
    end

    # => List the Servers with a Label
    def servers_labeled
      nr_api.get(url('servers'), 'filter[labels]' => 'Environment:Production').body
    # => rescue NoMethodError
    # =>   []
    end

    # => List the Servers Reporting to NewRelic
    def servers
      nr_api.get(url('servers')).body['servers']
    rescue NoMethodError
      []
    end

    # => Delete a Server from NewRelic
    def delete_server(server_id)
      nr_api.delete(url('servers', server_id)).body
    end

    # => Add an Entitity to an Existing Alert Policy
    def alert_add_entity(entity_id, condition_id, entity_type = 'Server')
      puts url('alerts_entity_conditions', entity_id)
      puts "entity_type=#{entity_type}&condition_id=#{condition_id}"
      nr_api.put do |req|
        req.url url('alerts_entity_conditions', entity_id)
        req.params['entity_type'] = entity_type
        req.params['condition_id'] = condition_id
      end
    end

    def url(*args)
      '/v2/' + args.map { |a| URI.encode_www_form_component a.to_s }.join('/') + '.json'
    end
    private :url
  end
end
