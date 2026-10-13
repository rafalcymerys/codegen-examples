class FinishReportTool < RubyLLM::Tool
  description "Notifies the system that the report is completed. The file at ENV['OUTPUT_FILE'] is validated and " \
              "saved as the report's table. If that fails the errors are returned so you can fix the output and " \
              "call this tool again."

  parameter :title, description: "A short title for the report"
  parameter :summary, description: "A short note for the user: what the report shows and any assumptions you made"

  def initialize(report)
    @report = report
  end

  def execute(title:, summary:)
    errors = Report::Result.new(@report).save(title:, summary:)

    if errors.any?
      @report.log("error", "The output is not a valid report table", errors.join("\n"))
      return { error: "The output is invalid, fix it and call this tool again.", details: errors }
    end

    FileUtils.rm_f([ @report.cats_path, @report.breeds_path ])
    @report.log("finished", "Report completed with #{@report.rows.size} rows")
    @report.transition_to!(:completed)
    { status: "completed", rows: @report.rows.size }
  rescue => e
    @report.log("error", "Saving the report failed", "#{e.class}: #{e.message}")
    { error: "Saving the report failed. Fix the output and call this tool again.",
      details: [ "#{e.class}: #{e.message}" ] }
  end
end
