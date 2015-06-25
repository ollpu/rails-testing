class AddTelegramColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :telegram_user, :text
  end
end
