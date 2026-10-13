class FinishChartTool < RubyLLM::Tool
  PNG_SIGNATURE = "\x89PNG\r\n\x1A\n".b
  MAX_BYTES = 10.megabytes
  DIMENSIONS = 200..4000

  description "Notifies the system that the chart is completed. The PNG file at ENV['OUTPUT_FILE'] is validated " \
              "and saved as the chart. If that fails the errors are returned so you can fix the file and call " \
              "this tool again."

  parameter :title, description: "A short title for the chart"
  parameter :summary, description: "A short note for the user: what the chart shows and any assumptions you made"

  def initialize(chart)
    @chart = chart
  end

  def execute(title:, summary:)
    errors = validate

    if errors.any?
      @chart.log("error", "The output is not a valid chart image", errors.join("\n"))
      return { error: "The chart image is invalid, fix it and call this tool again.", details: errors }
    end

    FileUtils.cp(@chart.output_path, @chart.image_path)
    FileUtils.rm_f([ @chart.cats_path, @chart.breeds_path ])
    @chart.log("finished", "Chart completed")
    @chart.transition_to!(:completed, title:, summary:)
    { status: "completed" }
  rescue => e
    @chart.log("error", "Saving the chart failed", "#{e.class}: #{e.message}")
    { error: "Saving the chart failed. Fix the file and call this tool again.", details: [ "#{e.class}: #{e.message}" ] }
  end

  private

  def validate
    path = @chart.output_path
    return [ "#{path.basename} does not exist. Write the PNG to the path in ENV['OUTPUT_FILE']." ] unless path.exist?
    return [ "The file is larger than #{MAX_BYTES / 1.megabyte} MB." ] if path.size > MAX_BYTES

    header = path.binread(24)
    return [ "The file is not a PNG image." ] unless header&.start_with?(PNG_SIGNATURE) && header.bytesize == 24

    width, height = header[16, 8].unpack("NN")
    return [] if DIMENSIONS.cover?(width) && DIMENSIONS.cover?(height)

    [ "The image is #{width}x#{height} pixels; both sides must be between #{DIMENSIONS.min} and #{DIMENSIONS.max}." ]
  end
end
