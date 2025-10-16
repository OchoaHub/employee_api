class ClientsController < ApplicationController
  def index
    clients = Clients::FetchList.new.call
    render json: clients.map { |c| c.to_h }
  rescue => e
    render json: { error: e.message }, status: :bad_gateway
  end
end
