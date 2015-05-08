class AddFieldsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :autor, :string
    add_column :comments, :text, :text
  end
end
