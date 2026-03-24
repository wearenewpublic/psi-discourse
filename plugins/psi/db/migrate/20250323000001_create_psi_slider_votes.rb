# frozen_string_literal: true

# Creates the psi_slider_votes table with unique (topic, user) constraint
# and a composite index on (topic, position) for efficient vote counting.
class CreatePsiSliderVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :psi_slider_votes do |t|
      t.references :topic, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :position, null: false
      t.references :post, foreign_key: true, null: true
      t.timestamps
    end

    add_index :psi_slider_votes, %i[topic_id user_id], unique: true
    add_index :psi_slider_votes, %i[topic_id position]
  end
end
