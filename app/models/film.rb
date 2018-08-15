# frozen_string_literal: true

class Film < ApplicationRecord
  include Swapi

  serialize :characters, Array

  # Public: Calls swapi and then creates the films based on the service.
  #
  # Returns an array of the created films
  def self.create_films
    Film.create(swapi_all)
  end

  # Public: Calls swapi and then creates the film based on the service.
  #
  # Returns a film
  def self.find_film(id)
    Film.create(swapi_find(id))
  end
end
