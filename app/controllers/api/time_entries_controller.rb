class API::TimeEntriesController < ApplicationController
    before_action :require_authentication
    before_action :require_admin, only: [:index_admin, :create_admin]

    # GET /time_entries
    def index
        if params[:start_date].present? && params[:end_date].present?
            start_date = params[:start_date]
            end_date = params[:end_date]
            @time_entries = current_user.time_entries.where(date: start_date..end_date).order(:date).paginate(page: params[:page], per_page: 25)
        else
            @time_entries = current_user.time_entries.order(:date).paginate(page: params[:page], per_page: 25)
        end

        total_pages = @time_entries.total_pages
        
        render json: {
            time_entries: @time_entries,
            total_pages: total_pages
        }
    end
    
    # GET /time_entries/admin
    def index_admin
        @time_entries = TimeEntry.all.order(:date).paginate(page: params[:page], per_page: 25)
        render json: @time_entries
    end

    # GET /time_entries/1
    def show
        @time_entry = TimeEntry.find(params[:id])
        
        if current_user == @time_entry.user || current_user.admin?
            render json: @time_entry
        else
            render_unauthorized("You do not have permission to access this time entry.")
        end
    end

    # POST /time_entries
    def create
        @time_entry = current_user.time_entries.new(time_entry_params)

        if @time_entry.save
            render json: @time_entry, status: :created
        else
            render json: @time_entry.errors, status: :unprocessable_entity
        end
    end

    # POST /time_entries/admin
    def create_admin
        @time_entry = TimeEntry.new(extended_time_entry_params)
        
        if @time_entry.save
            render json: @time_entry, status: :created
        else
            render json: @time_entry.errors, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /time_entries/1
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

    # DELETE /time_entries/1
    def destroy
        @time_entry = TimeEntry.find(params[:id])

        if current_user&.admin? || current_user == @time_entry.user
            @time_entry.destroy
            render json: { message: 'Time entry has been deleted' }
        else
            render_unauthorized("You do not have permission to delete this time entry.")
        end
    end
    
    # GET /time_entries/weekly_reports
    def weekly_reports
        time_entries = current_user.time_entries

        entries_by_week = time_entries.group_by { |entry| entry.date.strftime('%U-%Y') }

        weekly_averages = entries_by_week.map do |week, entries|
            total_distance = entries.sum(&:distance)
            average_distance = total_distance / entries.size

            total_time = entries.sum { |entry| entry.hours * 3600 + entry.minutes * 60 + entry.seconds }

            average_speed = total_distance / total_time * 3600

            { week: week, average_speed: average_speed, average_distance: average_distance }
        end

        weekly_averages = weekly_averages.sort_by { |average| [average[:week].split('-').last, average[:week].split('-').first] }.reverse

        page = params[:page] || 1
        per_page = 25
        total_entries = weekly_averages.length
      
        @paginated_averages = WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
          pager.replace(weekly_averages[pager.offset, pager.per_page])
        end
        
        @total_pages = (total_entries / per_page).floor + 1

        render json: {
            weekly_averages: @paginated_averages,
            total_pages: @total_pages
        }
    end

    private
        def time_entry_params
            params.require(:time_entry).permit(:date, :distance, :hours, :minutes, :seconds)
        end

        def extended_time_entry_params
            params.require(:time_entry).permit(:user_id, :date, :distance, :hours, :minutes, :seconds)
        end
end
