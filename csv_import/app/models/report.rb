class Report < ApplicationRecord
  include DataAnalysis

  def kind = "report"

  def agent_class = ReportAgent
  def agent_inputs = { report: self }
  def result_partial = "reports/result"
end
