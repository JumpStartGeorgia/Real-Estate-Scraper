#!/usr/bin/env ruby

##############################################################
## after the first complete run, the code to save the 
## price into dollars was not set, so this goes through
## all json files and sets it.
##############################################################

require 'json'
require 'logger'
require 'fileutils'
require_relative 'utilities'

start = Time.now

# log file to record messages
# delete existing log file
@log = Logger.new('makler.log')
@missing_param_log = Logger.new('makler_missing_params.log')

@log.info "**********************************************"
@log.info "**********************************************"
@log.info "Set Currency script started"

empty_files = 0
count = 0
Dir.foreach(@data_path) do |folder|
  if ['.', '..'].index(folder).nil?
    # get each json file in this folder and update the currency
    Dir.glob(@data_path + folder + "/**/*.json").sort.each do |json_file|      
puts json_file    
      if File.size?(json_file).nil?
        puts "file #{json_file} does not have any data, so skipping"
        empty_files += 1
        next
      end
      
      # pull in json
      json = JSON.parse(File.read(json_file))
      made_update = false
      
      # if the currency is 'price negotiable', reset to nil
      if !json['details']['sale_price'].nil? && !@non_number_price_text.index{|x| !x.index(json['details']['sale_price']).nil?}.nil?
        json['details']['sale_price'] = nil
        json['details']['sale_price_currency'] = nil
        json['details']['sale_price_dollars'] = nil
        json['details']['sale_price_sq_meter_dollars'] = nil
        made_update = true
      end      
      
      # if the currency is known, convert to dollars
      if !json['details']['sale_price_currency'].nil?
        currency_index = @currencies.keys.index(json['details']['sale_price_currency'].downcase)
        if !currency_index.nil?
          # price
          if !json['details']['sale_price'].nil?
            price = json['details']['sale_price'].to_f
            json['details']['sale_price_dollars'] = price * @currencies.values[currency_index]
            json['details']['sale_price_exchange_rate_to_dollars'] = @currencies.values[currency_index]
            
            made_update = true
          end
          # price per sq meter
          if !json['details']['sale_price_sq_meter'].nil?
            price = json['details']['sale_price_sq_meter'].to_f
            json['details']['sale_price_sq_meter_dollars'] = price * @currencies.values[currency_index]
            
            made_update = true
          end
        else
          @missing_param_log.error "Missing currency exchange #{json['details']['sale_price_currency']} in record #{json['posting_id']}"
        end
      end
      
      # if the currency is 'price negotiable', reset to nil
      if !json['details']['rent_price'].nil? && !@non_number_price_text.index{|x| !x.index(json['details']['rent_price']).nil?}.nil?
        json['details']['rent_price'] = nil
        json['details']['rent_price_currency'] = nil
        json['details']['rent_price_dollars'] = nil
        json['details']['rent_price_sq_meter_dollars'] = nil
        made_update = true
      end      
      

      # if the currency is known, convert to dollars
      if !json['details']['rent_price_currency'].nil?
        currency_index = @currencies.keys.index(json['details']['rent_price_currency'].downcase)
        if !currency_index.nil?
          # price
          if !json['details']['rent_price'].nil?
            price = json['details']['rent_price'].to_f
            json['details']['rent_price_dollars'] = price * @currencies.values[currency_index]
            
            made_update = true
          end
          # price per sq meter
          if !json['details']['rent_price_sq_meter'].nil?
            price = json['details']['rent_price_sq_meter'].to_f
            json['details']['rent_price_sq_meter_dollars'] = price * @currencies.values[currency_index]
            json['details']['rent_price_exchange_rate_to_dollars'] = @currencies.values[currency_index]
            
            made_update = true
          end
        else
          @missing_param_log.error "Missing currency exchange #{json['details']['sale_rent_currency']} in record #{json['posting_id']}"
        end
      end
      
      if made_update
        # save the changs to file
        File.open(json_file, 'w') { |f| f.write(json.to_json) }

        if count % 100 == 0
          puts "files processed so far = #{count} taking #{Time.now-start} seconds"
        end
        count += 1 
      end

    end
  end
end


@log.info "------------------------------"
@log.info "Set Currency script took #{Time.now - start} seconds to update #{count} json files; #{empty_files} file(s) were empty and skipped"
@log.info "------------------------------"


