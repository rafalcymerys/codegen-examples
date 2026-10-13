# Validates an import agent's output file against a table's FIELDS and loads
# it into that table, replacing the rows that were there. Returns a list of
# human readable errors (empty on success) so the agent can fix its output
# and try again.
class TableLoader
  MAX_REPORTED_ERRORS = 25

  def initialize(path, fields, records)
    @path = path
    @fields = fields
    @records = records
  end

  def call
    rows, errors = parse
    return errors if errors.any?

    attributes = rows.each_with_index.map { |row, index| normalize(row, index, errors) }
    return errors.first(MAX_REPORTED_ERRORS) + overflow(errors) if errors.any?

    @records.transaction do
      @records.delete_all
      @records.create!(attributes)
    end
    []
  end

  private

  def parse
    return [ nil, [ "#{@path.basename} does not exist. Write the result to the path in ENV['OUTPUT_FILE']." ] ] unless @path.exist?

    rows = JSON.parse(@path.read)
    return [ nil, [ "The output must be a JSON array of objects." ] ] unless rows.is_a?(Array) && rows.all?(Hash)

    [ rows, [] ]
  rescue JSON::ParserError => e
    [ nil, [ "The output is not valid JSON: #{e.message.truncate(200)}" ] ]
  end

  def normalize(row, index, errors)
    unknown = row.keys - @fields.keys.map(&:to_s)
    errors << "Row #{index}: unknown keys #{unknown.join(', ')}" if unknown.any?

    @fields.to_h do |field, spec|
      value = row[field.to_s]
      value = value.strip.presence if value.is_a?(String)
      errors << "Row #{index}: #{field} is missing" if value.nil?
      [ field, value.nil? ? nil : cast(field, spec, value, index, errors) ]
    end
  end

  def cast(field, spec, value, index, errors)
    case spec[:type]
    when "date" then Date.iso8601(value.to_s)
    when "number" then BigDecimal(value.to_s)
    else
      errors << "Row #{index}: #{field} must be one of #{spec[:values].join(', ')}, got #{value.inspect}" if spec[:values]&.exclude?(value)
      value.to_s
    end
  rescue ArgumentError, TypeError
    expected = { "date" => "an ISO 8601 date (YYYY-MM-DD)", "number" => "a number" }
    errors << "Row #{index}: #{field} must be #{expected.fetch(spec[:type])}, got #{value.inspect}"
    nil
  end

  def overflow(errors)
    extra = errors.size - MAX_REPORTED_ERRORS
    extra.positive? ? [ "...and #{extra} more errors" ] : []
  end
end
