class ExtractPayloadWorker
  include Sidekiq::Worker

  def perform(policy_id, textract_job_id)
    client = Aws::Textract::Client.new

    res = client.get_document_analysis({ job_id: textract_job_id })
    if(res.blocks.present?)
      policy = Policy.find(policy_id)
      ExtractPayloadService.call(policy, res)
    else
      self.class.perform_in(1.minute, policy_id, textract_job_id)
    end
  end
end
