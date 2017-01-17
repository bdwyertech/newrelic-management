# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: newrelic-management
# NewRelicManagement:: Util
#
# Copyright (C) 2017 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'json'

module NewRelicManagement
  # => Utility Methods
  module Util
    module_function

    #####################
    # =>    Cache    <= #
    #####################

    # => Cache Return of a Function
    def cachier(label, time = 30, &block)
      var = "@_cachier_#{label}"
      cache = instance_variable_get(var) || {}
      return cache['data'] if cache['timestamp'] && Time.now <= cache['timestamp'] + time
      cache['timestamp'] = Time.now
      cache['data'] = block.yield
      instance_variable_set(var, cache)
      cache['data']
    end

    # => Clear Cache
    def cachier!(var = nil)
      if var && instance_variable_get("@#{var}")
        # => Clear the Single Variable
        remove_instance_variable("@#{var}")
      else
        # => Clear the Whole Damned Cache
        instance_variables.each { |x| remove_instance_variable(x) }
      end
    end

    ########################
    # =>    File I/O    <= #
    ########################

    # => Define JSON Parser
    def parse_json(file = nil, symbolize = true)
      return unless file && ::File.exist?(file.to_s)
      begin
        ::JSON.parse(::File.read(file.to_s), symbolize_names: symbolize)
      rescue JSON::ParserError
        return
      end
    end

    # => Define JSON Writer
    def write_json(file, object)
      return unless file && object
      begin
        File.open(file, 'w') { |f| f.write(JSON.pretty_generate(object)) }
      end
    end

    # => Check if a string is an existing file, and return it's content
    def filestring(file, size = 8192)
      return unless file
      return file unless file.is_a?(String) && File.file?(file) && File.size(file) <= size
      File.read(file)
    end

    #############################
    # =>    Serialization    <= #
    #############################

    def serialize(response)
      # => Serialize Object into JSON Array
      JSON.pretty_generate(response.map(&:name).sort_by(&:downcase))
    end

    def serialize_csv(csv)
      # => Serialize a CSV String into an Array
      return unless csv && csv.is_a?(String)
      csv.split(',')
    end

    # => Return Common Elements of an Array
    def common_array(ary) # rubocop: disable AbcSize
      return ary unless ary.is_a? Array
      count = ary.count
      return ary if count.zero?
      return ary.flatten.uniq if count == 1
      common = ary[0] & ary[1]
      return common if count == 2
      (count - 2).times { |x| common &= ary[x + 2] } if count > 2
      common
    end
  end
end
