require 'json'
require 'date'

class Car
    attr_accessor :file, :cars, :rentals, :output, :options
    def initialize
        file = File.read('./data/input.json')
        data_hash = JSON.parse(file)
        @cars = data_hash['cars']
        @rentals = data_hash['rentals']
        @options = data_hash['options']
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

    def actions(price, days, options)
        commission = (price * 0.3).to_i
        insurance_fee = (commission / 2)
        assistance_fee = (days * 100)
        drivy_fee = (commission - insurance_fee - assistance_fee)
        reste = (price - commission)

        options.each do |options|
            if options == "gps"
                reste += 500 * days
                price += 500 * days
            elsif options == "baby_seat"
                reste += 200 * days
                price += 200 * days
            elsif options == "additional_insurance"
                drivy_fee += 1000 * days
                price += 1000 * days
          end
        end

        return [
            {"who" => "driver", "type" => "debit", "amount" => price},
            {"who" => "owner", "type" => "credit", "amount" => reste},
            {"who" => "insurance", "type" => "credit", "amount" => insurance_fee},
            {"who" => "assistance", "type" => "credit", "amount" => assistance_fee},
            {"who" => "drivy", "type" => "credit", "amount" => drivy_fee}
        ]
        
    end

    def get_rental_price_by_car(rental, car, options)
        price_per_day = car['price_per_day']
        price_per_km = car['price_per_km']
        distance = rental['distance']
        days = (Date.parse(rental['end_date']).mjd - Date.parse(rental['start_date']).mjd + 1) 

        price_per_day = apply_discount_by_day(price_per_day, days).to_i
        price = (price_per_day * days) + (price_per_km * distance)
        actions = actions(price, days, options)

        rental = {"id" => rental['id'], "options" => options, "actions" => actions}
        return rental
    end

    def compute_price
        local_output = []
        @rentals.each do |rental|
            car = @cars.find { |car| car['id'] == rental['car_id'] }
            options = @options.filter_map { |option| (option['rental_id'] == rental['id']) ? option['type'] : nil }
            rental_info = get_rental_price_by_car(rental, car, options)
            local_output.push(rental_info)
        end
        return @output = {"rentals" => local_output}
    end
end

puts JSON.pretty_generate(Car.new.compute_price)