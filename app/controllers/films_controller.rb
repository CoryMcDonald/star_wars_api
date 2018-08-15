# frozen_string_literal: true

class FilmsController < ApplicationController
  def index
    @films = Film.all

    respond_to do |format|
      format.json { render json: @films }
      format.html
    end
  end

  def show
    begin
      @film = Film.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @film = Film.create_film(params[:id])
    end

    respond_to do |format|
      format.json { render json: @film }
      format.html
    end
  end
end
