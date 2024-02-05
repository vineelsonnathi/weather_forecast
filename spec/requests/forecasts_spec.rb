# spec/requests/forecasts_spec.rb
require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "POST /forecasts" do
    it "creates forecast data" do
      post '/forecasts', params: { address: 'New York' }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("<turbo-stream")
      expect(response.body).to include("Current Forecast")
      expect(response.body).to include("Future Forecast")
    end
  end
end
