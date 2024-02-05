# frozen_string_literal: true

class ForecastService
  attr_accessor :latitude, :longitude, :address

  def initialize(params)
    @address = params[:address]
    @latitude, @longitude = Geocoder.search(@address).first&.coordinates
  end

  def run
    @latitude.blank? || @longitude.blank? ? {} : forecast_details
  end

  private

  def forecast_details
    cached_data = Rails.cache.read("forecast_#{address}")
    return cached_data.merge!(cached: true) if cached_data.present?

    Rails.cache.fetch("forecast_#{address}", expires_in: 30.minutes) do
      current_forecast = build_response(response: OpenWeather::Current.geocode(@latitude, @longitude, options).deep_symbolize_keys)

      future_forecast = {}
      forecast_response = OpenWeather::Forecast.geocode(@latitude, @longitude, options)
      forecast_list = forecast_response.deep_symbolize_keys![:list]

      forecast_list.each do |forecast_data|
        timestamp = forecast_data[:dt_txt]
        future_forecast[timestamp] = build_response(response: forecast_data)
      end

      { current_forecast: current_forecast, future_forecast: future_forecast, cached: false }
    end
  end

  def current_forecast
    build_response(
      response: OpenWeather::Current.geocode(@latitude, @longitude, options).deep_symbolize_keys
    )
  end

  def future_forecast
    future_forecast_hash = {}

    forecast_response = OpenWeather::Forecast.geocode(@latitude, @longitude, options)
    forecast_list = forecast_response.deep_symbolize_keys![:list]

    forecast_list.each do |forecast_data|
      timestamp = forecast_data[:dt_txt]
      future_forecast_hash[timestamp] = build_response(response: forecast_data)
    end

    future_forecast_hash
  end


  def build_response(response:)
    {
      temperature: response.dig(:main, :temp),
      min: response.dig(:main, :temp_min),
      max: response.dig(:main, :temp_max)
    }
  end

  def options
    {
      lang: 'en',
      units: 'imperial',
      APPID: Rails.application.credentials.open_weather[:api_key]
    }
  end
end
