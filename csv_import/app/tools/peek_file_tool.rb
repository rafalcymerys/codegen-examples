class PeekFileTool < RubyLLM::Tool
  MAX_LENGTH = 4096

  description "Looks at raw bytes of the uploaded file, by default the first 1024. " \
              "Use it to figure out what kind of file the user uploaded before processing it with Ruby code."

  parameter :length, type: :integer, description: "Number of bytes to read (max #{MAX_LENGTH}, default 1024)", required: false
  parameter :offset, type: :integer, description: "Byte offset to start reading from (default 0)", required: false

  def initialize(run)
    @run = run
  end

  def execute(length: 1024, offset: 0)
    length = length.to_i.clamp(1, MAX_LENGTH)
    offset = [ offset.to_i, 0 ].max
    bytes = File.binread(@run.input_path, length, offset) || "".b
    text = bytes.dup.force_encoding(Encoding::UTF_8)

    @run.log("tool", "Looked at #{bytes.bytesize} bytes of the file (offset #{offset})")

    {
      file_name: @run.original_filename,
      total_size: @run.byte_size,
      offset:,
      bytes_read: bytes.bytesize,
      encoding: text.valid_encoding? ? "utf-8" : "binary (shown as an escaped Ruby string)",
      content: text.valid_encoding? ? text : bytes.inspect
    }
  end
end
