class ChartsController < ApplicationController
  before_action :set_import, only: %i[new create]
  before_action :set_chart, only: %i[show destroy retry image]

  def new
    @chart = @cat_import.charts.new
  end

  def show
  end

  def create
    @chart = @cat_import.charts.new(prompt: params.dig(:chart, :prompt).to_s.strip)

    if @chart.save
      AgentRunJob.perform_later(@chart)
      redirect_to @chart
    else
      render :new, status: :unprocessable_entity
    end
  end

  def retry
    AgentRunJob.perform_later(@chart) if @chart.failed?
    redirect_to @chart
  end

  def image
    return head(:not_found) unless @chart.completed? && @chart.image_path.exist?

    send_file @chart.image_path, type: "image/png", disposition: params[:download] ? "attachment" : "inline",
                                 filename: "#{@chart.name.parameterize.presence || "chart"}.png"
  end

  def destroy
    @chart.destroy!
    redirect_to @chart.cat_import, notice: "Chart deleted."
  end

  private

  # Charts need the imported cats, so they are only available once the import has finished.
  def set_import
    @cat_import = CatImport.find(params[:cat_import_id])
    redirect_to @cat_import, alert: "Charts can be created once the import has completed." unless @cat_import.completed?
  end

  def set_chart
    @chart = Chart.find(params[:id])
  end
end
