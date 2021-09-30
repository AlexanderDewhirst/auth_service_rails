class CreateBlockedJwts < ActiveRecord::Migration[6.1]
  def change
    create_table :blocked_jwts do |t|
      t.string :token, null: false

      t.timestamps
    end

    add_reference :blocked_jwts, :user, foreign_key: true, index: true
  end
end
