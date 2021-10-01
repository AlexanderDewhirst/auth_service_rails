class CreateRefreshTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :refresh_tokens do |t|
      t.string :token, null: false

      t.timestamps
    end

    add_reference :refresh_tokens, :user, foreign_key: true, index: true
  end
end
