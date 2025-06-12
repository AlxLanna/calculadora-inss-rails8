class AddUserRefToProponentes < ActiveRecord::Migration[8.0]
  def change
    add_reference :proponentes, :user, null: false, foreign_key: true
  end
end
