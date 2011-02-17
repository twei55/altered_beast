class AddMailFlagsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :signed_newsletter, :boolean, :default => false
    add_column :users, :signed_notifications, :boolean, :default => false
  end

  def self.down
    remove_column :users, :signed_notifications
    remove_column :users, :signed_newsletter
  end
end