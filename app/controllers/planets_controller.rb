class PlanetsController < ApplicationController
  before_filter :set_page_title_and_tab_active
  before_filter :load_planets, only: [:index]
  before_filter :load_planet, only: [:edit, :show, :update, :destroy]

  def index
  end

  def create
    @planet = Planet.new(planet_params)

    if @planet.save
      redirect_to planets_url, notice: 'Planet was successfully created.'
    end
  end

  def new
    @planet = Planet.new
  end

  def edit
  end

  def show
    render :edit
  end

  def update
    if @planet.update(planet_params)
      redirect_to @planet, notice: 'Planet was successfully updated.'
    end
  end

  def destroy
    @planet.destroy
    redirect_to planets_url, notice: 'Planet was successfully destroyed.'
  end

  private

  def set_page_title_and_tab_active
    @page_title = "Planets"
    @active = 'planets'
  end

  def load_planet
    @planet = Planet.where(id: params[:id]).take
    raise Exception.new('Planet not found') unless @planet
  end

  def load_planets
    @planets = Planet.all
  end

  def planet_params
    params.require(:planet).permit(:name, :distance, :habitable)
  end
end
