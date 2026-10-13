class FinishImportTool < RubyLLM::Tool
  description "Notifies the system that the transformation has finished. The file at ENV['OUTPUT_FILE'] is " \
              "validated against the target structure and loaded into the table. If validation fails the errors " \
              "are returned so you can fix the output and call this tool again."

  parameter :summary, description: "A short summary for the user: what the file was, how it was mapped, " \
                                   "and anything that was skipped or could not be mapped"

  def initialize(run)
    @run = run
  end

  def execute(summary:)
    errors = @run.load_output

    if errors.any?
      @run.log("error", "The output did not match the target structure", errors.join("\n"))
      return { error: "The output is invalid, fix it and call this tool again.", details: errors }
    end

    count = @run.target_records.count
    @run.log("finished", "Imported #{count} #{@run.target_name}")
    @run.transition_to!(:completed, summary:)
    { status: "completed", imported_rows: count }
  rescue => e
    @run.log("error", "Saving the data failed", "#{e.class}: #{e.message}")
    { error: "Saving the data failed, nothing was imported. Fix the output and call this tool again.",
      details: [ "#{e.class}: #{e.message}" ] }
  end
end
