class RemoveAutorFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :autor, :string
    add_column :comments, :author, :string
  end
end
