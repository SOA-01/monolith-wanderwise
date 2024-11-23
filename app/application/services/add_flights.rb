# frozen_string_literal: true

require 'dry/transaction'
require_relative '../../infrastructure/database/repositories/flights'

module WanderWise
  module Service
    # Service to store flight data
    class AddFlights
      include Dry::Transaction

      step :find_flights
      step :store_flights

      private

      def find_flights(input)
        input = flights_from_amadeus(input)

        Success(input)
      rescue StandardError
        Failure('Could not find flights')
      end

      def store_flights(input)
        Repository::For.klass(Entity::Flight).create_many(input.value!)

        Success(input.value!)
      rescue StandardError
        Failure('Could not save flight data')
      end

      def flights_from_amadeus(input)
        amadeus_api = AmadeusAPI.new
        flight_mapper = FlightMapper.new(amadeus_api)
        flight_data = flight_mapper.find_flight(input)

        if flight_data.empty? || flight_data.nil?
          Failure('No flights found for the given criteria.')
        else
          Success(flight_data)
        end
      end
    end
  end
end
