class AddAttachmentPdfToPolicies < ActiveRecord::Migration[6.0]
  def self.up
    change_table :policies do |t|
      t.attachment :pdf
    end
  end

  def self.down
    remove_attachment :policies, :pdf
  end
end
