class CatImportsController < ApplicationController
  before_action :set_import, only: %i[show destroy retry]

  def index
    @cat_imports = CatImport.order(created_at: :desc)
  end

  def show
  end

  def create
    upload = params[:file]
    return redirect_to(root_path, alert: "Please choose a file to import.") unless upload.respond_to?(:tempfile)

    cat_import = CatImport.create_from_upload!(upload, name: params[:name])
    AgentRunJob.perform_later(cat_import)
    redirect_to cat_import
  end

  def retry
    AgentRunJob.perform_later(@cat_import) if @cat_import.failed?
    redirect_to @cat_import
  end

  def destroy
    @cat_import.destroy!
    redirect_to root_path, notice: "Import deleted."
  end

  private

  def set_import
    @cat_import = CatImport.find(params[:id])
  end
end
