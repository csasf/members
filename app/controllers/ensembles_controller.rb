class EnsemblesController < ApplicationController
  before_action :set_ensemble, only: [:show, :edit, :update, :destroy]

  # GET /ensembles
  # GET /ensembles.json
  def index
    @ensembles = Ensemble.all
  end

  # GET /ensembles/1
  # GET /ensembles/1.json
  def show
    @audit_string = helpers.generate_audit_array(@ensemble)
  end

  # GET /ensembles/new
  def new
    unless current_user.global_admin?
      redirect_to ensembles_url, notice: 'You do not have permissions to add ensembles' and return
    end
    @ensemble = Ensemble.new
  end

  # GET /ensembles/1/edit
  def edit
    unless current_user.global_admin?
      redirect_to @ensemble, notice: 'You do not have permissions to edit ensembles' and return
    end
  end

  # POST /ensembles
  # POST /ensembles.json
  def create
    unless current_user.global_admin?
      redirect_to ensembles_url, notice: 'You do not have permissions to create ensembles' and return
    end
    @ensemble = Ensemble.new(ensemble_params)

    respond_to do |format|
      if @ensemble.save
        format.html { redirect_to @ensemble, notice: 'Ensemble was successfully created.' }
        format.json { render :show, status: :created, location: @ensemble }
      else
        format.html { render :new }
        format.json { render json: @ensemble.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ensembles/1
  # PATCH/PUT /ensembles/1.json
  def update
    unless current_user.global_admin?
      redirect_to @ensemble, notice: 'You do not have permissions to edit ensembles' and return
    end
    respond_to do |format|
      if @ensemble.update(ensemble_params)
        format.html { redirect_to @ensemble, notice: 'Ensemble was successfully updated.' }
        format.json { render :show, status: :ok, location: @ensemble }
      else
        format.html { render :edit }
        format.json { render json: @ensemble.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ensembles/1
  # DELETE /ensembles/1.json
  def destroy
    @ensemble.destroy
    respond_to do |format|
      format.html { redirect_to ensembles_url, notice: 'Ensemble was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ensemble
    @ensemble = Ensemble.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ensemble_params
    params.require(:ensemble).permit(
      :name,
      :description
    )
  end
end
