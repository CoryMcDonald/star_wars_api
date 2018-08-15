# frozen_string_literal: true

class PeopleController < ApplicationController
  def index
    @people = Person.all

    respond_to do |format|
      format.json { render json: @people }
      format.html
    end
  end

  def show
    begin
      @person = Person.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @person = Person.create_person(params[:id])
    end

    respond_to do |format|
      format.json { render json: @person.as_json }
      format.html
    end
  end
end
