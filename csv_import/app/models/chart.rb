# A chart the chart agent draws from an import's cats and breeds, stored as a
# PNG in the run's directory.
class Chart < ApplicationRecord
  include DataAnalysis

  def kind = "chart"

  # Where the agent writes the PNG, and where it is kept once it was accepted.
  def output_path = workdir.join("output.png")
  def image_path = workdir.join("chart.png")

  def agent_class = ChartAgent
  def agent_inputs = { chart: self }
  def result_partial = "charts/result"
end
