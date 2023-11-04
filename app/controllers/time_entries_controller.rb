class TimeEntriesController < ApplicationController
    before_action :require_authentication
    before_action :require_admin, only: [:index_admin, :create_admin]

    # GET /entries
    def index
        @time_entries = current_user.time_entries.order(:date).paginate(page: params[:page], per_page: 25)
        render json: @time_entries
    end
    
    # GET /entries/admin
    def index_admin
        @time_entries = TimeEntry.all.order(:date).paginate(page: params[:page], per_page: 25)
        render json: @time_entries
    end

    # GET /entries/1
    def show
        @time_entry = TimeEntry.find(params[:id])
        
        if current_user == @time_entry.user || current_user.admin?
            render json: @time_entry
        else
            render_unauthorized("You do not have permission to access this time entry.")
        end
    end

    # POST /entries
    def create
        @time_entry = current_user.time_entries.new(time_entry_params)

        if @time_entry.save
            render json: @time_entry, status: :created
        else
            render json: @time_entry.errors, status: :unprocessable_entity
        end
    end

    # POST /entries/admin
    def create_admin
        @time_entry = TimeEntry.new(extended_time_entry_params)
        
        if @time_entry.save
            render json: @time_entry, status: :created
        else
            render json: @time_entry.errors, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /entries/1
    def update
        @time_entry = TimeEntry.find(params[:id])

        if current_user&.admin? || current_user == @time_entry.user
            if @time_entry.update(time_entry_params)
                render json: @time_entry
            else
                render json: @time_entry.errors, status: :unprocessable_entity
            end
        else
            render_unauthorized("You do not have permission to update this time entry.")
        end
    end

    # DELETE /entries/1
    def destroy
        @time_entry = TimeEntry.find(params[:id])

        if current_user&.admin? || current_user == @time_entry.user
            @time_entry.destroy
            render json: { message: 'Time entry has been deleted' }
        else
            render_unauthorized("You do not have permission to delete this time entry.")
        end
    end
    
    # GET /entries/filtered_by_dates
    def filter_by_dates
        start_date = params[:start_date]
        end_date = params[:end_date]
      
        time_entries = current_user.time_entries.where(date: start_date..end_date)
        render json: time_entries
      end
    
    # GET /entries/weekly_reports
    def weekly_reports
        time_entries = current_user.time_entries

        entries_by_week = time_entries.group_by { |entry| entry.date.strftime('%U-%Y') }

        weekly_averages = entries_by_week.map do |week, entries|
            average_speed = entries.sum(&:speed) / entries.size
            average_distance = entries.sum(&:distance) / entries.size

            { week: week, average_speed: average_speed, average_distance: average_distance }
        end

        render json: weekly_averages
    end

    private
        def time_entry_params
            params.require(:time_entry).permit(:date, :distance, :hours, :minutes, :seconds)
        end

        def extended_time_entry_params
            params.require(:time_entry).permit(:user_id, :date, :distance, :hours, :minutes, :seconds)
        end
end
