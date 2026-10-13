class CatImport < ApplicationRecord
  include TableImport

  has_many :cats, dependent: :delete_all
  has_many :breeds, dependent: :delete_all
  has_many :breed_imports, dependent: :destroy
  has_many :breed_assignments, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :charts, dependent: :destroy

  validates :name, :original_filename, presence: true

  def self.create_from_upload!(upload, name: nil)
    filename = File.basename(upload.original_filename.to_s).presence || "upload"
    cat_import = create!(name: name.presence || filename, original_filename: filename, byte_size: upload.size)
    FileUtils.mkdir_p(cat_import.workdir)
    FileUtils.cp(upload.tempfile.path, cat_import.input_path)
    cat_import
  end

  # The uploaded file, kept untouched.
  def input_path = workdir.join("input")

  # Links every cat whose breed_name matches the name of one of the import's
  # breeds (ignoring case and surrounding whitespace) to that breed.
  def link_cats_to_breeds
    cats.update_all(breed_id: nil)
    breeds.pluck(:id, :name).each do |id, name|
      cats.where("lower(trim(breed_name)) = ?", name.strip.downcase).update_all(breed_id: id)
    end
  end

  def load_output
    super.tap { |errors| link_cats_to_breeds if errors.empty? }
  end

  def target_fields = Cat::FIELDS
  def target_records = cats

  def agent_class = CatImportAgent
  def agent_inputs = { cat_import: self }
  def result_partial = "cat_imports/cats"

  def kickoff_message
    "Please import the uploaded file. Its original name is #{original_filename.inspect} and it is #{byte_size} bytes long."
  end

  def script_environment
    { "INPUT_FILE" => input_path.to_s, "OUTPUT_FILE" => output_path.to_s }
  end
end
