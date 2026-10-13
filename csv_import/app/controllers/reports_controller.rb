class ReportsController < ApplicationController
  before_action :set_import, only: %i[new create]
  before_action :set_report, only: %i[show destroy retry]

  def new
    @report = @cat_import.reports.new
  end

  def show
  end

  def create
    @report = @cat_import.reports.new(prompt: params.dig(:report, :prompt).to_s.strip)

    if @report.save
      AgentRunJob.perform_later(@report)
      redirect_to @report
    else
      render :new, status: :unprocessable_entity
    end
  end

  def retry
    AgentRunJob.perform_later(@report) if @report.failed?
    redirect_to @report
  end

  def destroy
    @report.destroy!
    redirect_to @report.cat_import, notice: "Report deleted."
  end

  private

  # Reports need the imported cats, so they are only available once the import has finished.
  def set_import
    @cat_import = CatImport.find(params[:cat_import_id])
    redirect_to @cat_import, alert: "Reports can be created once the import has completed." unless @cat_import.completed?
  end

  def set_report
    @report = Report.find(params[:id])
  end
end
