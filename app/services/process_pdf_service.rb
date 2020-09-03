class ProcessPdfService
  extend Service

  def initialize(policy)
    @pdf_processor = HexaPDF::Document
    @textract_client = Aws::Textract::Client.new
    @s3_client = Aws::S3::Client.new
    @s3_bucket = ENV['AWS_BUCKET']
    @pdf_key = policy.pdf.path.sub(/^\//, "")
    @page_number = policy.page_number
    @policy = policy
    @textract_job_id = nil
    @page_s3_key = nil
    @page = nil
    @pdf = nil
  end

  def call
    set_policy_processing_status
    download_pdf
    extract_page
    start_analyzing
    schedule_result_check
  ensure
    clear_files
  end

  private
  attr_accessor :pdf, :pdf_processor, :page, :page_number, :textract_client,
                :pdf_key, :s3_client, :s3_bucket, :page_s3_key, :textract_job_id,
                :policy



  def set_policy_processing_status
    policy.update!(status: 'Processing...')
  end

  def download_pdf
    @pdf = "#{Rails.root}/tmp/temp_pdf.pdf"

    File.open(pdf, 'wb') do |file|
      s3_client.get_object(
        {
          bucket: s3_bucket,
          key: pdf_key
        },
        target: file
      )
    end
  end

  def extract_page
    @page = "#{Rails.root}/tmp/#{page_number}.pdf"

    separate_page = pdf_processor.open(download_pdf.body).pages[page_number - 1]
    separate_page_pdf = pdf_processor.new
    separate_page_pdf.pages << separate_page_pdf.import(separate_page)
    separate_page_pdf.write(page)

    @page_s3_key = pdf_key.split('/')[0...-1].join('/')

    s3_client.put_object(
      {
        body: File.read(page),
        bucket: s3_bucket,
        key: page_s3_key
      }
    )
  end

  def start_analyzing
    res = textract_client.start_document_analysis(
      {
        document_location: {
          s3_object: {
            bucket: s3_bucket,
            name: page_s3_key
          }
        },
        feature_types: ["TABLES"]
      }
    )

    @textract_job_id = res.job_id
  end

  def schedule_result_check
    ExtractPayloadWorker.perform_in(1.minute, policy.id, textract_job_id)
  end

  def clear_files
    File.delete(page) if page
    File.delete(pdf) if pdf
  end
end
