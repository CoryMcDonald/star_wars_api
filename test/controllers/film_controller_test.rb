# frozen_string_literal: true

require 'test_helper'

class FilmControllerTest < ActionDispatch::IntegrationTest
  test 'index when no format is specified' do
    get(films_path)
    assert_response :success
    assert_equal 'text/html', @response.content_type
  end

  test 'index when json is specified' do
    get(films_path, as: :json)

    films = JSON.parse(@response.body)
    assert_equal 7, films.length
    assert_equal 'application/json', @response.content_type
  end

  test 'show when json is specified' do
    get(film_path(id: 1), as: :json)

    film = JSON.parse(@response.body)
    assert_equal 4, film['episode_id']
  end

  test 'show when no format is specified' do
    get(film_path(id: 1))
    assert_response :success
    assert_equal 'text/html', @response.content_type
  end
end
