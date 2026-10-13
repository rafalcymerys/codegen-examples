class AgentQuestion < ApplicationRecord
  belongs_to :subject, polymorphic: true

  scope :answered, -> { where.not(answered_at: nil) }
  scope :unanswered, -> { where(answered_at: nil) }

  validates :question, :tool_call_id, presence: true

  def answered? = answered_at.present?
end
