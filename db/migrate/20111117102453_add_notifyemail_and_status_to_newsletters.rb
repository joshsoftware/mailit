class AddNotifyemailAndStatusToNewsletters < ActiveRecord::Migration
  def self.up
    add_column :newsletters, :notify_email, :string
    add_column :newsletters, :mailer_status, :string , :default => "sending"
  end

  def self.down
    remove_column :newsletters, :notify_email
    remove_column :newsletters, :mailer_status
  end
end
