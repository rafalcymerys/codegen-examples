class DescribeTargetStructureTool < RubyLLM::Tool
  description "Returns how the target table is constructed, i.e. the structure the source data has to be " \
              "transformed into: the list of columns with their types and the expected output format."

  def initialize(run)
    @run = run
  end

  def execute
    @run.log("tool", "Checked the target structure")

    {
      table: @run.target_name,
      output_format: "A JSON array of objects written to the path in ENV['OUTPUT_FILE'], one object per row, " \
                     "using exactly the keys below. Every key is required and no value may be null or empty. " \
                     "Dates are ISO 8601 strings, numbers are JSON numbers.",
      columns: @run.target_fields.map { |name, spec| { name:, **spec } }
    }
  end
end
