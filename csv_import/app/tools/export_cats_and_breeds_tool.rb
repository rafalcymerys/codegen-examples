require "csv"

class ExportCatsAndBreedsTool < RubyLLM::Tool
  description "Exports the cats and the breeds of the import from the database into two temporary CSV files " \
              "(with header rows) and returns their paths. The paths are also in ENV['CATS_FILE'] and " \
              "ENV['BREEDS_FILE'] for your scripts. Call it again to see the current state after assigning breeds."

  CAT_COLUMNS = %i[id name breed_name breed_id].freeze
  BREED_COLUMNS = %i[id name origin].freeze

  def initialize(assignment)
    @assignment = assignment
  end

  def execute
    import = @assignment.cat_import
    FileUtils.mkdir_p(@assignment.workdir)
    write(@assignment.cats_path, CAT_COLUMNS, import.cats.order(:id))
    write(@assignment.breeds_path, BREED_COLUMNS, import.breeds.order(:id))

    unassigned = import.cats.where(breed_id: nil).count
    @assignment.log("tool", "Exported #{import.cats.count} cats (#{unassigned} without a breed) and #{import.breeds.count} breeds")

    {
      cats: { path: @assignment.cats_path.to_s, rows: import.cats.count, without_breed: unassigned,
              columns: "id, name (the cat's name), breed_name (the breed as written in the source), " \
                       "breed_id (the assigned breed, empty if none)" },
      breeds: { path: @assignment.breeds_path.to_s, rows: import.breeds.count, columns: "id, name, origin" },
      format: "CSV, comma separated, UTF-8, first row is the header."
    }
  end

  private

  def write(path, columns, records)
    CSV.open(path, "w") do |csv|
      csv << columns
      records.each { |record| csv << columns.map { |column| record.public_send(column) } }
    end
  end
end
