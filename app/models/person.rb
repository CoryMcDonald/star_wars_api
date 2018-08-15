# frozen_string_literal: true

class Person < ApplicationRecord
  include Swapi
  serialize :films, Array

  after_find do |person|
    # The typical workflow is through find() thus the liklihood
    # of someone calling .all on this model is negligible
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) do
      p = Person.send(:swapi_find, person.id, person.etag)
      person.update(p) if p.present?
      person
    end
  end

  # Public: Calls swapi and then creates the people based on the service.
  #
  # Returns an array of the created people
  def self.create_people
    Person.create(swapi_all)
  end

  # Public: Calls swapi and then creates a person based on the service.
  #
  # id - the id of the resource
  #
  # Returns a person
  def self.create_person(id)
    Person.create(swapi_find(id))
  end
end
