# frozen_string_literal: true

require 'test_helper'

class ApiDatabaseSynchronizationTest < ActionDispatch::IntegrationTest
  test 'sanity for films' do
    Film.swapi_all.each do |swapi_film|
      api_film = Film.new(swapi_film)

      film = Film.find(swapi_film[:id])
      assert_equal film, api_film
    end
  end

  test 'sanity for people' do
    Person.swapi_all.each do |swapi_person|
      api_person = Person.new(swapi_person)

      person = Person.find(swapi_person[:id])
      assert_equal person, api_person
    end
  end
end
