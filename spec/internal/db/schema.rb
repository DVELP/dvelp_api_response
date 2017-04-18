# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table(:child_records, force: true) do |t|
    t.belongs_to :test_record
    t.string :name
  end

  create_table(:test_records, force: true) do |t|
    t.string :name
    t.text   :content
    t.timestamps
  end
end
