# An agent run that answers a user's request from an import's cats and
# breeds (reports and charts). Including classes define: agent_class,
# agent_inputs, result_partial and kind (e.g. "report").
module DataAnalysis
  extend ActiveSupport::Concern
  include AgentRun

  included do
    belongs_to :cat_import

    validates :prompt, presence: true
  end

  def name = title.presence || kind.capitalize

  # The import's cats and breeds, exported for the agent's scripts (see ExportDataTool).
  def cats_path = workdir.join("cats.csv")
  def breeds_path = workdir.join("breeds.csv")

  def script_environment
    { "CATS_FILE" => cats_path.to_s, "BREEDS_FILE" => breeds_path.to_s, "OUTPUT_FILE" => output_path.to_s }
  end

  def kickoff_message
    "Please create a #{kind} from the data of the import #{cat_import.name.inspect} " \
      "(#{pluralize_count(cat_import.cats.count, "cat")}, #{pluralize_count(cat_import.breeds.count, "breed")}). " \
      "This is what the user wants in the #{kind}:\n\n#{prompt}"
  end

  private

  def pluralize_count(count, word) = "#{count} #{word.pluralize(count)}"
end
