# An import of breeds from an API, for a cat import. Each successful run replaces
# the import's breeds.
class BreedImport < ApplicationRecord
  include TableImport

  belongs_to :cat_import

  validates :url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/, message: "must be an http(s) URL" }

  # The breeds are replaced, so the cats' links to the old ones are dropped
  # (and kept if the output is invalid). Cats are not linked to the new
  # breeds automatically: that is the job of a BreedAssignment.
  def load_output
    errors = []
    CatImport.transaction do
      cat_import.cats.update_all(breed_id: nil)
      errors = super
      raise ActiveRecord::Rollback if errors.any?
    end
    errors
  end

  def target_fields = Breed::FIELDS
  def target_records = cat_import.breeds

  def agent_class = BreedImportAgent
  def agent_inputs = { breed_import: self }
  def result_partial = "breeds/table"
  def result_locals = { cat_import: }

  def kickoff_message
    "Please import the cat breeds from this API: #{url}"
  end

  def script_environment
    { "API_URL" => url, "OUTPUT_FILE" => output_path.to_s }
  end
end
