class LayersController < ApplicationController
  # Require the user to login for all actions except index/show
  before_filter :authenticate_user!, :except => [:index, :show]

  # Only allow the map's owner to create/new, update/edit or destroy
  # a layer of the map
  before_filter :except => [:index, :show] do
    @map = Map.find(params[:map_id])

    if current_user != @map.user
      flash[:error] = "You must be logged in as the owner " +
        "of this map to modify its layers"
      redirect_to new_user_session_url
    end
  end

  # GET maps/1/layers
  # GET maps/1/layers.json
  def index
    @map = Map.find(params[:map_id])
    @layers = @map.layers

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @layers }
    end
  end

  # GET maps/1/layers/1
  # GET maps/1/layers/1.json
  def show
    @map = Map.find(params[:map_id])
    @layer = @map.layers.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.text { render :text => @layer.get_wkt(params) }
      format.json {
        if params[:as_geo_json]
          render :json => @layer.get_geo_json(params)
        else
          render :json => @layer
        end
      }
    end
  end

  # GET maps/1/layers/new
  # GET maps/1/layers/new.json
  def new
    @layer = @map.layers.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @layer }
    end
  end

  # GET maps/1/layers/1/edit
  def edit
    @layer = @map.layers.find(params[:id])
  end

  # POST maps/1/layers
  # POST maps/1/layers.json
  def create
    @layer = @map.layers.build(params[:layer])

    respond_to do |format|
      if @layer.save
        format.html { redirect_to([@layer.map, @layer], :notice => 'Layer was successfully created.') }
        format.json { render :json => @layer, :status => :created, :location => [@layer.map, @layer] }
      else
        format.html { render :action => "new" }
        format.json { render :json => @layer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT maps/1/layers/1
  # PUT maps/1/layers/1.json
  def update
    @layer = @map.layers.find(params[:id])

    respond_to do |format|
      if @layer.update_attributes(params[:layer])
        format.html { redirect_to([@layer.map, @layer], :notice => 'Layer was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @layer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE maps/1/layers/1
  # DELETE maps/1/layers/1.json
  def destroy
    @layer = @map.layers.find(params[:id])
    @layer.destroy

    respond_to do |format|
      format.html { redirect_to map_layers_url(@map) }
      format.json { head :ok }
    end
  end
end
