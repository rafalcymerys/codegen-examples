# A run of the breed assignment agent, which links every cat of an import to
# one of the import's breeds.
class BreedAssignment < ApplicationRecord
  include AgentRun

  belongs_to :cat_import

  def cats_path = workdir.join("cats.csv")
  def breeds_path = workdir.join("breeds.csv")

  def agent_class = BreedAssignmentAgent
  def agent_inputs = { breed_assignment: self }
  def result_partial = "breed_assignments/cats"
  def result_locals = { cat_import: }

  def kickoff_message
    cats = cat_import.cats
    "Please assign a breed to every cat of the import #{cat_import.name.inspect}. It has #{cats.count} cats, " \
      "#{cats.where(breed_id: nil).count} of them without a breed, and #{cat_import.breeds.count} breeds."
  end

  def script_environment
    { "CATS_FILE" => cats_path.to_s, "BREEDS_FILE" => breeds_path.to_s, "OUTPUT_FILE" => output_path.to_s }
  end
end
