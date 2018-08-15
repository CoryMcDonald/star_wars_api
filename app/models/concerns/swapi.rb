# frozen_string_literal: true

require 'net/http'

module Swapi
  extend ActiveSupport::Concern

  module ClassMethods
    SWAPI_BASE = 'https://swapi.co/api/'
    SWAPI_END = '/?format=json'

    CACHE_EXPIRATION = 1.hours

    # Methods selected from the querying interface in ActiveRecord
    # https://github.com/rails/rails/blob/v5.2.0/activerecord/lib/active_record/querying.rb
    QUERY_METHODS = %w[where select first].freeze

    ALL_NET_HTTP_ERRORS = [
      Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    ].freeze

    # Public: Makes call to database and API to synchronize between the two.
    #         By default Rails delegates each ActiveRecord call to .all
    #         However we only want to synchronize with the API when the user is making a batch call
    #         We use reflection to get the calling method and determine if it's appropriate
    #         to make an HTTP Request
    #
    # Returns an ActiveRecord::Relation for the model
    def all
      caller = caller_locations(1..1).first.label
      all_records = super

      # Check cache, if it's expired then make API call to check if ids are synchronized
      Rails.cache.fetch("all_records/#{name}", expires_in: CACHE_EXPIRATION) do
        return all_records if QUERY_METHODS.include? caller

        # Synchronize if the caller is not getting a specific object
        synchronize_records(all_records)
        all_records = super
      end

      all_records
    end

    def synchronize_records(all_records)
      api_results = swapi_all
      missing_ids = missing_ids(api_results, all_records)

      return if missing_ids.empty?

      missing_records = api_results.select { |x| missing_ids.include?(x[:id]) }
      create(missing_records)
    end

    # Public: Given results from the api and a database returns ids
    #         that are in the API but not in the database
    #
    # Returns an array of Integer
    def missing_ids(api_list, database_list)
      api_ids = api_list.map { |x| x[:id] }
      database_ids = database_list.map(&:id)

      api_ids - database_ids
    end

    # Public: Gets all records from an endpoint
    #
    # url - an optional string which represents url to call
    #       used primarly for recursively getting all objects
    #
    # Returns a hash of the valid properties for the model
    def swapi_all(url = nil)
      all_results = []
      uri = URI(url || swapi_url)

      request = Net::HTTP.get_response(uri)
      response = JSON.parse(request.body)

      # Recursively get all results if the endpoint is paginated
      all_results.concat(swapi_all(response['next'])) if response['next'].present?

      all_results.concat(
        response['results'].map { |r| format_response(r, etag: request['etag']) }
      )
    rescue *ALL_NET_HTTP_ERRORS
      Rails.logger.error e.message
      []
    end

    # Public: Finds an object from the service
    #
    # etag - optional entity tag for the request that
    #
    # Returns either a valid hash of the found resource,
    #  or nil indicating that the found resource was not modified
    def swapi_find(id, etag = nil)
      uri = URI(swapi_url(id))
      request = Net::HTTP::Get.new(uri)
      request['If-None-Match'] = etag if etag

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      # If the following issue gets resolved
      # https://github.com/phalt/swapi/issues/92
      # Then we could make a "If-None-Match" request with the stored etag and only update if we got a Status code of 304
      # Until then let's check the etag status
      return nil if response.code == '304' || response['etag'] == etag

      format_response(JSON.parse(response.body), etag: response['etag'])
    rescue *ALL_NET_HTTP_ERRORS
      Rails.logger.error e.message
    end

    private

    # Internal: Formats a hash into an object that can be parsed by the model
    #
    # hash - the hash which to format
    # etag - the etag from the response header
    #
    # Returns a hash with valid values for the model
    def format_response(hash, etag)
      hash.delete_if { |k, _| !attribute?(k.to_s) }
      # Generate the resource identifier via url because swapi doesn't return that in the body
      swapi_id = hash['url'].split('/').last
      hash[:id] = swapi_id.to_i
      hash.merge!(etag)
    end

    # Internal: Determines if the attribute passed in exists on the model
    #
    # attribute - the name of the attribute to validate
    #
    # Returns a boolean if the attribute is on the model
    def attribute?(attribute)
      attribute_names.index(attribute)
    end

    # Internal: Calculates the swapi_url based on the consuming class
    #
    # Returns the url for the endpoint
    def swapi_url(id = nil)
      url = SWAPI_BASE + name.downcase.pluralize
      url += "/#{id}" if id.present?
      url + SWAPI_END
    end
  end
end
