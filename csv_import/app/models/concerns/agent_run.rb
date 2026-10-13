# Shared behaviour of records an agent works on in the background (imports and
# reports): status, persisted conversation, questions to the user, activity
# log, a scratch directory and live updates of the page.
#
# Including classes define: agent_class, agent_inputs, kickoff_message,
# script_environment and result_partial (rendered with result_locals).
module AgentRun
  extend ActiveSupport::Concern

  STATUSES = %w[pending processing waiting_for_user completed failed].freeze

  included do
    belongs_to :chat, optional: true, dependent: :destroy
    has_many :questions, class_name: "AgentQuestion", as: :subject, dependent: :delete_all
    has_many :events, class_name: "AgentEvent", as: :subject, dependent: :delete_all

    enum :status, STATUSES.index_by(&:itself), default: "pending"

    after_destroy_commit { FileUtils.rm_rf(workdir) }
  end

  # Everything the agent touches for this run lives in this directory.
  def workdir = Rails.root.join("storage", model_name.plural, Rails.env, id.to_s)
  def output_path = workdir.join("output.json")

  def result_locals = { model_name.element.to_sym => self }

  def pending_question = questions.unanswered.order(:id).first

  def log(kind, message, detail = nil)
    events.create!(kind:, message:, detail:)
  end

  def transition_to!(status, **attributes)
    update!(status:, **attributes)
    broadcast_state
  end

  def broadcast_state
    broadcast_replace_to self, target: "run_status", partial: "agent_runs/status", locals: { run: self }
    broadcast_replace_to self, target: "run_question", partial: "agent_runs/question", locals: { run: self }
    broadcast_replace_to self, target: "run_result", partial: result_partial, locals: result_locals
  end
end
