class Cat < ApplicationRecord
  GENDERS = %w[male female other].freeze

  # The target structure every import is transformed into. This is the single
  # source of truth for the agent (DescribeTargetStructureTool), the validation
  # of its output (TableLoader) and the table shown in the UI. breed_id is not
  # part of it: it is derived from breed_name.
  # Every field is required: a cat with a missing value cannot be imported.
  FIELDS = {
    name:             { type: "string", description: "The cat's name" },
    breed_name:       { type: "string", description: "The cat's breed, as written in the source" },
    owner_first_name: { type: "string", description: "Owner's first name" },
    owner_last_name:  { type: "string", description: "Owner's last name" },
    street:           { type: "string", description: "Owner's street address including house/apartment number" },
    zipcode:          { type: "string", description: "Owner's postal code, kept as text (preserve leading zeros)" },
    city:             { type: "string", description: "Owner's city" },
    birthday:         { type: "date",   description: "The cat's date of birth, ISO 8601 (YYYY-MM-DD)" },
    gender:           { type: "string", description: "The cat's gender, one of: #{GENDERS.join(', ')}", values: GENDERS },
    weight:           { type: "number", description: "The cat's weight, in the unit the source uses" },
    favorite_food:    { type: "string", description: "The cat's favorite food" },
    last_vet_visit:   { type: "date",   description: "Date of the cat's last vet visit, ISO 8601 (YYYY-MM-DD)" }
  }.freeze

  belongs_to :cat_import
  # Set by CatImport#link_cats_to_breeds when cats are imported and breed_name
  # matches one of the import's breeds, and by the breed assignment agent.
  belongs_to :breed, optional: true

  validates(*FIELDS.keys, presence: true)
  validates :gender, inclusion: { in: GENDERS }
  validates :weight, numericality: { greater_than: 0 }
end
