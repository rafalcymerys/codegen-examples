class BreedsController < ApplicationController
  def index
    @cat_import = CatImport.find(params[:cat_import_id])
    @breed_import = @cat_import.breed_imports.order(:id).last
  end
end
