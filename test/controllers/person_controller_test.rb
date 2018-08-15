# frozen_string_literal: true

require 'test_helper'

class PersonControllerTest < ActionDispatch::IntegrationTest
  test 'index when no format is specified' do
    get(people_path)
    assert_response :success
    assert_equal 'text/html', @response.content_type
  end

  test 'index when json is specified' do
    get(people_path, as: :json)

    people = JSON.parse(@response.body)
    assert_equal true, people.length > 1
    assert_equal 'application/json', @response.content_type
  end

  test 'show when json is specified' do
    get(person_path(id: 1), as: :json)

    film = JSON.parse(@response.body)
    assert_equal 'Luke Skywalker', film['name']
  end

  test 'show when no format is specified' do
    get(person_path(id: 1))
    assert_response :success
    assert_equal 'text/html', @response.content_type
  end
end
