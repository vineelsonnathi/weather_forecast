require 'rails_helper'

RSpec.describe ForecastService do
  let(:params) { { address: 'New York' } }
  let(:latitude) { 40.7128 }
  let(:longitude) { -74.0060 }

  describe '#initialize' do
    it 'sets address, latitude, and longitude' do
      allow(Geocoder).to receive(:search).and_return([double(coordinates: [latitude, longitude])])
      service = ForecastService.new(params)
      
      expect(service.address).to eq('New York')
      expect(service.latitude).to eq(latitude)
      expect(service.longitude).to eq(longitude)
    end
  end

  describe '#run' do
    context 'when latitude or longitude is empty' do
      it 'returns an empty hash' do
        service = ForecastService.new({ address: '' })
        expect(service.run).to eq({})
      end
    end

    context 'when latitude and longitude are present' do
      it 'returns forecast details' do
        allow(Geocoder).to receive(:search).and_return([double(coordinates: [latitude, longitude])])
        allow(Rails.application.credentials).to receive(:open_weather).and_return(api_key: 'fake_api_key')
        allow(OpenWeather::Current).to receive(:geocode).and_return({ main: { temp: 25 } })
        allow(OpenWeather::Forecast).to receive(:geocode).and_return({ list: [{ dt_txt: '2024-02-01', main: { temp: 30 } }] })

        service = ForecastService.new(params)
        forecast_data = service.run

        expect(forecast_data).to eq({
          current_forecast: { temperature: 25, min: nil, max: nil },
          future_forecast: { '2024-02-01' => { temperature: 30, min: nil, max: nil } },
          cached: false
        })
      end
    end
  end
end
