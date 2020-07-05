class Policy < ApplicationRecord
  has_attached_file :pdf,
                    storage: :s3,
                    s3_permissions: 'private',
                    s3_region: ENV['AWS_REGION'],
                    s3_credentials: Proc.new{|a| a.instance.s3_credentials }
  validates_attachment :pdf, content_type: { content_type: ["application/pdf"] }

  validates :page_number, presence: true

  def s3_credentials
    {
      bucket: ENV['AWS_BUCKET'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  end
end
