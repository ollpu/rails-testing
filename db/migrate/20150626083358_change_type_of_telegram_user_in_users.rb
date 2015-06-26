class ChangeTypeOfTelegramUserInUsers < ActiveRecord::Migration
  def change
    remove_column :users, :telegram_user, :text
    add_column :users, :telegram_user, :boolean, default: false
  end
end
