class BreedAssignmentsController < ApplicationController
  def index
    @cat_import = CatImport.find(params[:cat_import_id])
    @breed_assignment = @cat_import.breed_assignments.order(:id).last
  end

  def create
    cat_import = CatImport.find(params[:cat_import_id])
    blocker = start_blocker(cat_import)
    return redirect_to(cat_import_breed_assignments_path(cat_import), alert: blocker) if blocker

    AgentRunJob.perform_later(cat_import.breed_assignments.create!)
    redirect_to cat_import_breed_assignments_path(cat_import)
  end

  def retry
    breed_assignment = BreedAssignment.find(params[:id])
    AgentRunJob.perform_later(breed_assignment) if breed_assignment.failed?
    redirect_to cat_import_breed_assignments_path(breed_assignment.cat_import)
  end

  private

  def start_blocker(cat_import)
    if cat_import.breeds.none? then "Import breeds first."
    elsif cat_import.cats.where(breed_id: nil).none? then "Every cat already has a breed."
    elsif cat_import.breed_assignments.where(status: %w[pending processing waiting_for_user]).any?
      "The agent is already assigning breeds."
    end
  end
end
