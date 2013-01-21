class LocationsController < ApplicationController
  include LocationsHelper

  def index
    @locations = Location.find :all
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(params[:location])
    if @location.save
      index
      render 'index'
    else
      render 'new'
    end
  end

  def show
    @location = Location.find(params[:id])
    @g4r_options = gmaps4rails_opts(@location)
  end

end