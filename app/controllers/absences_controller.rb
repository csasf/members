class AbsencesController < ApplicationController
  before_action :set_absence, only: [:show, :edit, :update, :destroy, :flip_excused_flag, :set_sub]
  before_action :authenticate_user!, except: [:index, :new, :create]

  # GET /absences
  # GET /absences.json
  def index
    unless current_user
      redirect_to new_absence_url
    end

    @member_email_statuses = Email.statuses_for_general_use
    @email_status = params[:e_status] || 2
    @email_status_name = @member_email_statuses[@email_status]


    @performance_sets = PerformanceSet.all.map { |ps| [ps.extended_name, ps.id] }
    @performance_sets = @performance_sets.unshift(['All Sets', 0])

    if params[:set]
      if PerformanceSet.where('id = ?', params[:set]).count > 0
        @member_sets = MemberSet.filtered_by_criteria(params[:set].to_i, @email_status)
        @perf_set = PerformanceSet.where('id = ?', params[:set]).first
        @performance_set_id = @perf_set.id

        @set_rehearsal_dates = @perf_set.performance_set_dates

        @performance_set = params[:set].to_i
        @performance_set_label = @performance_set
      end
    end

    @absences = Absence.includes(:member).includes(performance_set_date: :performance_set).all
    if @performance_set
      @absences = @absences.to_a.keep_if {|a| a.performance_set_date && a.performance_set_date.performance_set_id == params[:set].to_i }
    end
  end

  # GET /absences/1
  # GET /absences/1.json
  def show
    @performance_sets = PerformanceSet.all
  end

  # GET /absences/new
  def new
    @performance_sets = PerformanceSet.now_or_future
    @absence = Absence.new
    render layout: 'anonymous' unless current_user.present?
  end

  # GET /absences/1/edit
  def edit
    @performance_sets = PerformanceSet.now_or_future
    @performance_set_dates = PerformanceSetDate.all
  end

  # POST /absences
  # POST /absences.json
  def create
    aparams = absence_params

    # figure out which member it is
    if aparams[:members][:email_1].blank?
      member = nil
    else
      member = Member.where('lower(email_1) = lower(?) OR lower(email_2) = lower(?)', aparams[:members][:email_1].strip, aparams[:members][:email_1].strip).first
    end

    if member
      aparams[:member_id] = member.id
    end
    aparams.delete(:members)

    # don't care which performance set it is
    aparams.delete(:performance_set_dates)

    @absence = Absence.new(aparams)
    @performance_sets = PerformanceSet.now_or_future

    respond_to do |format|
      if @absence.save
        if !current_user
          format.html { redirect_to new_absence_url, notice: 'Absence was successfully recorded. You can record another absence below.' }
        else
          format.html { redirect_to @absence, notice: 'Absence was successfully created.' }
          format.json { render :show, status: :created, location: @absence }
        end
      else
        if current_user
          # Bugsnag.notify("Absence creation error (logged in)")
          format.html { render :new }
        else
          # Bugsnag.notify("Absence creation error")
          format.html { render :new, layout: 'anonymous' }
        end
        format.json { render json: @absence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /absences/1
  # PATCH/PUT /absences/1.json
  def update
    @performance_sets = PerformanceSet.now_or_future

    respond_to do |format|
      if @absence.update(absence_params)
        format.html { redirect_to @absence, notice: 'Absence was successfully updated.' }
        format.json { render :show, status: :ok, location: @absence }
      else
        format.html { render :edit }
        format.json { render json: @absence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /absences/1
  # DELETE /absences/1.json
  def destroy
    @absence.destroy
    respond_to do |format|
      format.html { redirect_to absences_url, notice: 'Absence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def flip_excused_flag
    @absence.planned = !@absence.planned
    @absence.save
    respond_to do |format|
      format.html { redirect_to absence_url(@absence), notice: 'Absence was successfully updated.' }
      format.json { head :no_content }
    end
  end

  def set_sub
    @absence.sub_found = absence_params[:sub_found]
    @absence.save
    respond_to do |format|
      format.html { redirect_to absence_url(@absence), notice: 'Absence was successfully updated.' }
      format.json { head :no_content }
    end
  end

  def record_attendance
    unless current_user
      redirect_to new_absence_url
    end

    if params[:set_rehearsal_date]
      if PerformanceSetDate.where('id = ?', params[:set_rehearsal_date]).count > 0
        @performance_set_date = PerformanceSetDate.where('id = ?', params[:set_rehearsal_date]).first
        @perf_set = @performance_set_date.performance_set
        @members = @perf_set.members
        @member_sets = @perf_set.member_sets.where('member_id != 0')
      end
    end

    @absences = Absence.includes(:member).all
    if @performance_set_date
      @absences = @absences.to_a.keep_if {|a| a.performance_set_date_id == params[:set_rehearsal_date].to_i }
    end
    respond_to do |format|
      format.html { render :record_attendance }
      format.json { head :no_content }
    end
  end

  def batch_create
    @_dangerous_params = request.parameters
    set_rehearsal_date = @_dangerous_params['set_rehearsal_date']
    @_dangerous_params.each do |param|
      if param[0] =~ /^absence_[0-9]+$/
        member_id = param[0][8..-1].to_i
        if @_dangerous_params["absence_#{member_id}_absence"]
          a = Absence.find_or_create_by!(member_id: member_id, performance_set_date_id: set_rehearsal_date)
          a.planned = @_dangerous_params["absence_#{member_id}_reported"]
          a.sub_found = @_dangerous_params["absence_#{member_id}_sub"]
          a.save
        else
          a = Absence.where(member_id: member_id, performance_set_date_id: set_rehearsal_date).destroy_all
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to record_attendance_absences_path(set_rehearsal_date: set_rehearsal_date), notice: 'Absences were successfully updated.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_absence
    @absence = Absence.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def absence_params
    params.require(:absence).permit(
      :member_id,
      :performance_set_id,
      :performance_set_date_id,
      :date,
      :planned,
      :sub_found,
      performance_set_dates: [
        :performance_set_id
      ],
      members: [
        :email_1
      ]
    )
  end
end
