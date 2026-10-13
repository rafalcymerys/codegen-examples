class AssignBreedsTool < RubyLLM::Tool
  MAX_LISTED = 50

  description "Saves breed assignments from ENV['OUTPUT_FILE'], a JSON array like " \
              '[{"cat_id": 1, "breed_id": 2}, ...]. Cats not listed keep their current breed. Returns the cats ' \
              "that still have no breed; when none are left the task is completed. Invalid input is rejected " \
              "with the errors, and nothing is saved."

  parameter :summary, description: "A short summary for the user: how the breeds were matched and any decisions " \
                                   "or assumptions, so far"

  def initialize(assignment)
    @assignment = assignment
  end

  def execute(summary:)
    pairs, errors = parse
    if errors.any?
      @assignment.log("error", "The assignments were rejected", errors.join("\n"))
      return { error: "The assignments are invalid and nothing was saved. Fix them and call this tool again.", details: errors }
    end

    cats = @assignment.cat_import.cats
    Cat.transaction do
      pairs.group_by(&:last).each { |breed_id, group| cats.where(id: group.map(&:first)).update_all(breed_id:) }
    end

    remaining = cats.where(breed_id: nil).order(:id)
    @assignment.log("tool", "Assigned breeds to #{pairs.size} #{"cat".pluralize(pairs.size)}, #{remaining.count} still without a breed")
    return complete(summary) if remaining.none?

    { assigned: pairs.size,
      still_without_breed: remaining.count,
      cats_without_breed: remaining.limit(MAX_LISTED).map { |cat| { cat_id: cat.id, name: cat.name, breed_name: cat.breed_name } },
      next_step: "Not every cat has a breed yet. Continue until all of them do, asking the user where you cannot decide." }
  rescue => e
    @assignment.log("error", "Saving the assignments failed", "#{e.class}: #{e.message}")
    { error: "Saving the assignments failed, nothing was saved. Fix the input and call this tool again.",
      details: [ "#{e.class}: #{e.message}" ] }
  end

  private

  def complete(summary)
    FileUtils.rm_f([ @assignment.cats_path, @assignment.breeds_path ])
    @assignment.log("finished", "Every cat has a breed")
    @assignment.transition_to!(:completed, summary:)
    { status: "completed", still_without_breed: 0 }
  end

  def parse
    path = @assignment.output_path
    return [ [], [ "#{path.basename} does not exist. Write the assignments to the path in ENV['OUTPUT_FILE']." ] ] unless path.exist?

    rows = JSON.parse(path.read)
    return [ [], [ 'The input must be a JSON array of objects like {"cat_id": 1, "breed_id": 2}.' ] ] unless rows.is_a?(Array) && rows.all?(Hash)

    validate(rows)
  rescue JSON::ParserError => e
    [ [], [ "The input is not valid JSON: #{e.message.truncate(200)}" ] ]
  end

  def validate(rows)
    cat_ids = @assignment.cat_import.cats.pluck(:id).to_set
    breed_ids = @assignment.cat_import.breeds.pluck(:id).to_set
    errors = []

    pairs = rows.each_with_index.filter_map do |row, index|
      cat_id, breed_id = row.values_at("cat_id", "breed_id")
      errors << "Entry #{index}: cat_id #{cat_id.inspect} is not a cat of this import" unless cat_ids.include?(cat_id)
      errors << "Entry #{index}: breed_id #{breed_id.inspect} is not a breed of this import" unless breed_ids.include?(breed_id)
      [ cat_id, breed_id ]
    end

    conflicting = pairs.group_by(&:first).select { |_, list| list.map(&:last).uniq.size > 1 }.keys
    errors << "Cats assigned to more than one breed: #{conflicting.join(', ')}" if conflicting.any?
    [ pairs.uniq, errors.first(25) ]
  end
end
