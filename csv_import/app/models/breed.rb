class Breed < ApplicationRecord
  # The target structure of a breeds import, used by the agent, the validation of
  # its output and the UI. Every field is required.
  FIELDS = {
    name:       { type: "string", description: "The breed's name" },
    origin:     { type: "string", description: "Where the breed comes from" },
    weight_min: { type: "number", description: "Lower end of the breed's typical weight, in the unit the source uses" },
    weight_max: { type: "number", description: "Upper end of the breed's typical weight, in the unit the source uses" }
  }.freeze

  NUMERIC_FIELDS = FIELDS.reject { |_, spec| spec[:type] == "string" }.keys.freeze

  belongs_to :cat_import
  has_many :cats, dependent: :nullify

  validates(*FIELDS.keys, presence: true)
  validates(*NUMERIC_FIELDS, numericality: true)
end
