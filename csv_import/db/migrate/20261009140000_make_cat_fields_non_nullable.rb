class MakeCatFieldsNonNullable < ActiveRecord::Migration[8.0]
  FIELDS = %i[owner_first_name owner_last_name street zipcode city birthday gender favorite_food last_vet_visit].freeze

  def up
    execute "UPDATE cats SET gender = 'unknown' WHERE gender IS NULL"
    FIELDS.each { |field| change_column_null :cats, field, false }
  end

  def down
    FIELDS.each { |field| change_column_null :cats, field, true }
  end
end
