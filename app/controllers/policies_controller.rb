class PoliciesController < ApplicationController
  def index
    policy = Policy.find_by(holder: params[:holder])

    if policy
      render json: policy.payload[params[:age]] || 0
    else
      head 404
    end
  end
end
