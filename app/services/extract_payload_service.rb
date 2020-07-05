class ExtractPayloadService
  extend Service

  def initialize(policy, textract_response)
    @policy = policy
    @blocks = textract_response.blocks
    @payload = nil
  end

  def call
    extract_payload
    update_policy
  end
  private

  attr_reader :policy, :blocks, :payload
  def extract_payload
    @payload = blocks.select do |b|
      b.block_type == 'CELL' &&  # pick only cells
        b.relationships.present? &&  # ensure cell have text
        b.row_index != 1 && # filter header
        (b.column_index == 1 || b.column_index == 8) # pick 1 and 8 columns
    end.group_by { |b| b.row_index }
       .inject({}) { |h, (k, v)| h[get_cell_text(v[0])] = get_cell_text(v[1]); h }
  end

  def get_cell_text(cell)
    blocks.find { |b| b.id == cell.relationships[0].ids[0] }.text
  end

  def update_policy
    policy.update!(payload: payload, status: 'Processed')
  end
end
