require "csv"

class ExportDataTool < RubyLLM::Tool
  description "Exports the cats and the breeds of the import from the database into two temporary CSV files " \
              "(with header rows) and returns their paths together with a description of the columns. The paths " \
              "are also in ENV['CATS_FILE'] and ENV['BREEDS_FILE'] for your scripts. Call it before writing scripts."

  CAT_COLUMNS = Cat::FIELDS.merge(
    breed_id: { type: "integer", description: "id of the cat's breed in the breeds file, empty if the cat has no breed assigned" }
  ).freeze
  BREED_COLUMNS = { id: { type: "integer", description: "The breed's id, referenced by breed_id in the cats file" } }
                    .merge(Breed::FIELDS).freeze

  def initialize(run)
    @run = run
  end

  def execute
    import = @run.cat_import
    FileUtils.mkdir_p(@run.workdir)
    cats = write(@run.cats_path, CAT_COLUMNS, import.cats.order(:id))
    breeds = write(@run.breeds_path, BREED_COLUMNS, import.breeds.order(:id))
    @run.log("tool", "Exported #{cats} cats and #{breeds} breeds to temporary CSV files")

    {
      format: "CSV, comma separated, UTF-8, first row is the header. Dates are ISO 8601 (YYYY-MM-DD).",
      cats: { path: @run.cats_path.to_s, row_count: cats, columns: describe(CAT_COLUMNS) },
      breeds: { path: @run.breeds_path.to_s, row_count: breeds, columns: describe(BREED_COLUMNS) }
    }
  end

  private

  def write(path, columns, records)
    CSV.open(path, "w") do |csv|
      csv << columns.keys
      records.each { |record| csv << columns.keys.map { |column| record.public_send(column) } }
    end
    records.size
  end

  def describe(columns) = columns.map { |name, spec| { name:, **spec } }
end
