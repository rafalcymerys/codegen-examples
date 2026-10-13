# Validates the report agent's output file and stores it on the report.
# Returns a list of human readable errors (empty on success) so the agent can
# fix its output and try again.
class Report::Result
  MAX_COLUMNS = 30
  MAX_ROWS = 2_000
  MAX_REPORTED_ERRORS = 25
  CELL_TYPES = [ String, Numeric, TrueClass, FalseClass, NilClass ].freeze

  def initialize(report)
    @report = report
  end

  def save(title:, summary:)
    data, errors = parse
    errors = validate(data) if errors.empty?
    return errors.first(MAX_REPORTED_ERRORS) if errors.any?

    @report.update!(title:, summary:, columns: data["columns"], rows: data["rows"])
    []
  end

  private

  def parse
    return [ nil, [ "#{@report.output_path.basename} does not exist. Write the result to the path in ENV['OUTPUT_FILE']." ] ] unless @report.output_path.exist?

    data = JSON.parse(@report.output_path.read)
    return [ nil, [ 'The output must be a JSON object: {"columns": [...], "rows": [[...], ...]}.' ] ] unless data.is_a?(Hash)

    [ data, [] ]
  rescue JSON::ParserError => e
    [ nil, [ "The output is not valid JSON: #{e.message.truncate(200)}" ] ]
  end

  def validate(data)
    columns, rows = data.values_at("columns", "rows")
    return [ '"columns" must be a non-empty array of strings.' ] unless columns.is_a?(Array) && columns.any? && columns.all? { |column| column.is_a?(String) && column.present? }
    return [ '"rows" must be an array of arrays.' ] unless rows.is_a?(Array) && rows.all?(Array)

    errors = []
    errors << "The report has #{columns.size} columns, at most #{MAX_COLUMNS} are allowed." if columns.size > MAX_COLUMNS
    errors << "The report has #{rows.size} rows, at most #{MAX_ROWS} are allowed. Aggregate or limit the data." if rows.size > MAX_ROWS
    rows.each_with_index do |row, index|
      errors << "Row #{index}: has #{row.size} values but there are #{columns.size} columns" if row.size != columns.size
      errors << "Row #{index}: values must be strings, numbers, booleans or null" unless row.all? { |cell| CELL_TYPES.any? { |type| cell.is_a?(type) } }
    end
    errors
  end
end
