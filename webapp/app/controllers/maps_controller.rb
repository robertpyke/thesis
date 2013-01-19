class MapsController < ApplicationController

  # Require the user to login for all actions except index/show
  before_filter :authenticate_user!, :except => [:index, :show]

  # Only allow the map's owner to update/edit or destroy it
  before_filter :only => [:update, :edit, :destroy] do
    @map = Map.find(params[:id])

    if current_user != @map.user
      flash[:error] = "You must be logged in as the owner of this map to modify it"
      redirect_to new_user_session_url
    end
  end

  # GET /maps
  # GET /maps.json
  def index
    @maps = Map.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @maps }
    end
  end

  # GET /maps/1
  # GET /maps/1.json
  def show
    @map = Map.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @map }
    end
  end

  # GET /maps/new
  # GET /maps/new.json
  def new
    @map = current_user.maps.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @map }
    end
  end

  # GET /maps/1/edit
  def edit
  end

  # POST /maps
  # POST /maps.json
  def create
    @map = current_user.maps.new(params[:map])

    respond_to do |format|
      if @map.save
        format.html { redirect_to @map, notice: 'Map was successfully created.' }
        format.json { render json: @map, status: :created, location: @map }
      else
        format.html { render action: "new" }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /maps/1
  # PUT /maps/1.json
  def update
    respond_to do |format|
      if @map.update_attributes(params[:map])
        format.html { redirect_to @map, notice: 'Map was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.json
  def destroy
    @map.destroy

    respond_to do |format|
      format.html { redirect_to maps_url }
      format.json { head :no_content }
    end
  end
end
