class ProcessPdfWorker
  include Sidekiq::Worker

  def perform(policy_id)
    policy = Policy.find(policy_id)

    ProcessPdfService.call(policy)
  end
end
