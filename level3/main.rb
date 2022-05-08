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

    def apply_discount_by_day(price, day)
        if day > 10
            price = price - (price * 0.5)
        elsif day > 4
            price = price - (price * 0.3)
        elsif day > 1
            price = price - (price * 0.1)
        end
        return price
    end

    def commission(price, days)
        commission = (price * 0.3).to_i
        insurance_fee = (commission / 2)
        assistance_fee = (days * 100)
        drivy_fee = (commission - insurance_fee - assistance_fee)
        return {"insurance_fee" => insurance_fee, "assistance_fee" => assistance_fee, "drivy_fee" => drivy_fee}
        
    end

    def get_rental_price_by_car(rental, car)
        price_per_day = car['price_per_day']
        price_per_km = car['price_per_km']
        distance = rental['distance']

        days = (Date.parse(rental['end_date']).mjd - Date.parse(rental['start_date']).mjd + 1) 
        price_per_day = apply_discount_by_day(price_per_day, days).to_i
        price = (price_per_day * days) + (price_per_km * distance)
        commission = commission(price, days)

        rental = {"id" => rental['id'], "price" => price, "commission" => commission}
        return rental
    end

    def compute_price
        local_output = []
        @rentals.each do |rental|
            car = @cars.find { |car| car['id'] == rental['car_id'] }
            rental_info = get_rental_price_by_car(rental, car)
            local_output.push(rental_info)
        end
        return @output = {"rentals" => local_output}
    end
end

puts JSON.pretty_generate(Car.new.compute_price)