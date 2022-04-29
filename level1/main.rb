require 'json'
require 'date'

class Car
    attr_accessor :file, :cars, :rentals, :output
    def initialize
        file = File.read('./data/input.json')
        data_hash = JSON.parse(file)
        @cars = data_hash['cars']
        @rentals = data_hash['rentals']
        @output = {}
    end
    def compute_price
        local_output = []
        @rentals.each do |rental|
            car = @cars.find { |car| car['id'] == rental['car_id'] }

            price_per_day = car['price_per_day']
            price_per_km = car['price_per_km']
            distance = rental['distance']

            days = Date.parse(rental['end_date']).mjd - Date.parse(rental['start_date']).mjd
            price = price_per_day * days + price_per_km * distance

            rental = {"id" => rental['id'], "price" => price}
            local_output.push(rental)
        end
        @output = {"rentals" => local_output}.to_json
    end
end

puts Car.new.compute_price