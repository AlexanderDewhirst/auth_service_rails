class CreateJwtBlacklists < ActiveRecord::Migration[6.1]
  def change
    create_table :blacklists do |t|
      t.string :token, null: false

      t.timestamps
    end

    add_reference :blacklists, :user, foreign_key: true, index: true
  end
end
