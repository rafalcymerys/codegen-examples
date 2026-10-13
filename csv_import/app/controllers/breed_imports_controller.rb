class BreedImportsController < ApplicationController
  def create
    cat_import = CatImport.find(params[:cat_import_id])
    breed_import = cat_import.breed_imports.new(url: params[:url].to_s.strip)

    if breed_import.save
      AgentRunJob.perform_later(breed_import)
      redirect_to cat_import_breeds_path(cat_import)
    else
      redirect_to cat_import_breeds_path(cat_import), alert: "The API URL #{breed_import.errors[:url].to_sentence}."
    end
  end

  def retry
    breed_import = BreedImport.find(params[:id])
    AgentRunJob.perform_later(breed_import) if breed_import.failed?
    redirect_to cat_import_breeds_path(breed_import.cat_import)
  end
end
