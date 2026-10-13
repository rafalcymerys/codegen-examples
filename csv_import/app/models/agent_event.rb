class AgentEvent < ApplicationRecord
  belongs_to :subject, polymorphic: true

  after_create_commit -> { broadcast_append_to subject, target: "run_events" }
end
