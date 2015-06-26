class ChangeTypeOfTelegramUserInUsersToInteger < ActiveRecord::Migration
  def change
    remove_column :users, :telegram_user, :boolean, default: false
    add_column :users, :telegram_user, :integer
  end
end
