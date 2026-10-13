class RenameImportsToCatImports < ActiveRecord::Migration[8.0]
  TABLES = %i[cats breeds breed_imports reports].freeze

  def change
    rename_table :imports, :cat_imports
    TABLES.each { |table| rename_column table, :import_id, :cat_import_id }

    reversible do |direction|
      direction.up { update_subject_types("Import", "CatImport") }
      direction.down { update_subject_types("CatImport", "Import") }
    end
  end

  private

  def update_subject_types(from, to)
    %w[agent_events agent_questions].each do |table|
      execute "UPDATE #{table} SET subject_type = '#{to}' WHERE subject_type = '#{from}'"
    end
  end
end
