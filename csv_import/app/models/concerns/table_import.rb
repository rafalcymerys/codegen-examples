# An agent run that fills a table (cats or breeds) from some source. The agent
# writes rows to the run's output file and they are validated against the
# table's FIELDS before they are loaded.
#
# Including classes define: target_fields and target_records.
module TableImport
  extend ActiveSupport::Concern
  include AgentRun

  def target_name = target_records.model_name.human.downcase.pluralize

  # Loads the agent's output into the target table. Returns validation errors.
  def load_output = TableLoader.new(output_path, target_fields, target_records).call
end
