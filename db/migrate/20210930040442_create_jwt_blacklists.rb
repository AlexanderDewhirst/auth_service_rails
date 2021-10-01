class CreateJwtBlacklists < ActiveRecord::Migration[6.1]
  def change
    create_table :blacklist_tokens do |t|
      t.string :token, null: false

      t.timestamps
    end

    add_reference :blacklist_tokens, :user, foreign_key: true, index: true
  end
end
