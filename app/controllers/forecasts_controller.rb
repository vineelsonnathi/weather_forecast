# frozen_string_literal: true

class ForecastsController < ApplicationController
  def get_forecast
    response = ForecastService.new(params).run
    @current_forecast = response[:current_forecast]
    @future_forecast = response[:future_forecast]
    @cached = response[:cached]

    respond_to do |format|
      format.js
      format.turbo_stream
    end
  end
end
