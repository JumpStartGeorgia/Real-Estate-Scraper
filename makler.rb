#!/usr/bin/env ruby
# encoding: utf-8

# gel example: http://makler.ge/?lan=2&pg=ann&id=10001182

##########################
## SCRAPER FOR makler.ge
##########################

require 'typhoeus'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'logger'
require 'fileutils'

require_relative 'utilities'
require_relative 'database'


@start = Time.now

# log file to record messages
# delete existing log file
@log = Logger.new('makler.log')
@missing_param_log = Logger.new('makler_missing_params.log')

@log.info "**********************************************"
@log.info "**********************************************"


# starting url 
@posting_url = "http://makler.ge/?pg=ann&id="
@serach_url = "http://makler.ge/?pg=search&cat=-1&tp=-1&city_id=-1&raion_id=0&price_f=&price_t=&valuta=2&sart_f=&sart_t=&rooms_f=&rooms_t=&ubani_id=0&street_id=0&parti_f=&parti_t=&mdgomareoba=0&remont=0&project=0&xedi=0&metro_id=0&is_detailed_search=2&sb=d"
@page_param = "&p="
@lang_param = "&lan="

# track processing status
@status = get_status
@found_all_ids = false


####################################################
@nbsp = Nokogiri::HTML("&nbsp;").text
####################################################


# process the response
def process_response(response)
  # pull out the locale and id from the url
  id = get_param_value(response.request.url, 'id')
  locale = get_param_value(response.request.url, 'lan')
  locale_key = get_locale_key(locale)
  
  if id.nil? || locale.nil? || locale_key.nil?
    @log.error "response url is not in expected format: #{response.request.url}; expected url to have params of 'id' and 'lan'"
    return
  end
  
  # get the name of the folder for this id
  # - the name is the id minus it's last 3 digits
  id_folder = get_parent_id_folder(id)
  folder_path = @data_path + id_folder + "/" + id + "/" + locale_key.to_s + "/"

  # get the response body
  doc = Nokogiri::HTML(response.body)
    
  if doc.css('td.table_content').length != 2
    @log.error "the response does not have any content to process"
    return
  end

  # save the response body
  file_path = folder_path + @response_file
	create_directory(File.dirname(file_path))
  File.open(file_path, 'w'){|f| f.write(doc)}
    
  # create the json
  json = json_template
  
  json[:posting_id] = id
  json[:locale] = locale_key.to_s
  
  # get the type/date
  header_row = doc.css('.div_for_content > .page_title')
  if header_row.length > 0
    span = header_row.css('span')
    if span.length == 0
      # the title is not correct so assume this is 
      # not a page that can be processed.
      # remove the id from the status list to indicate it was processed
      remove_status_json_id(id, locale_key.to_s)

      @log.warn "the id #{id} with language #{locale} does not have any data"

      return
    end 
    type_text = span[0].xpath('text()').text.strip
    json[:type] = get_page_type(type_text, locale).to_s
    json[:property_type] = get_property_type(type_text, locale).to_s

    date = header_row.css('span')[header_row.css('span').length-1].xpath('text()').text.strip
    # need to convert from dd/mm/yyyy to yyyy-mm-dd
    json[:date] = Date.strptime(date, '%d.%m.%Y').strftime
  end
  
  # details info
  details_titles = doc.css('td.mc_title')
  details_values = doc.css('td.mc_title + td')
  if details_titles.length > 0 && details_values.length > 0
    details_titles.each_with_index do |title, title_index|
      title_text = title.text.strip.downcase
      # get the index for the key with this text
      index = @locales[locale_key][:keys][:details].values.index{|x| title_text == x}
      if index
        # get the key name for this text
        key = @locales[locale_key][:keys][:details].keys[index]
        
        # save the value
        json[:details][key] = details_values[title_index].text.strip    
        
        if !json[:details][key].nil? && json[:details][key].length > 0
          # if this is a sale price, pull out the price and price per sq meter
          if @sale_keys.include?(key) && !@non_number_price_text.include?(json[:details][key])
            prices = json[:details][key].split('/')
            price_ary = prices[0].strip.split(' ')
            
            json[:details][:sale_price] = price_ary[0].strip
            json[:details][:sale_price_currency] = price_ary[1].strip if !price_ary[1].nil?

            # if price per sq meter present, save it
            if prices.length > 1
              json[:details][:sale_price_sq_meter] = prices[1].strip.split(' ')[0].strip
            end

            # if the currency is known, convert to dollars
            if !json[:details][:sale_price_currency].nil?
              currency_index = @currencies.keys.index(json[:details][:sale_price_currency].downcase)
              if !currency_index.nil?
                # exchange rate
                json[:details][:sale_price_exchange_rate_to_dollars] = @currencies.values[currency_index]
                
                # price
                if !json[:details][:sale_price].nil?
                  price = json[:details][:sale_price].to_f
                  json[:details][:sale_price_dollars] = price * @currencies.values[currency_index]
                end
                # price per sq meter
                if !json[:details][:sale_price_sq_meter].nil?
                  price = json[:details][:sale_price_sq_meter].to_f
                  json[:details][:sale_price_sq_meter_dollars] = price * @currencies.values[currency_index]
                end
              else
                @missing_param_log.error "Missing currency exchange #{json[:details][:sale_price_currency]} in record #{id}"
              end
            end
            

          # if this is a rent price, pull out the price and price per sq meter
          elsif @rent_keys.include?(key) && !@non_number_price_text.include?(json[:details][key])
            prices = json[:details][key].split('/')
            price_ary = prices[0].strip.split(' ')
            
            json[:details][:rent_price] = price_ary[0].strip
            json[:details][:rent_price_currency] = price_ary[1].strip if !price_ary[1].nil?
            
            # if price per sq meter present, save it
            if prices.length > 1
              json[:details][:rent_price_sq_meter] = prices[1].strip.split(' ')[0].strip
            end


            # if the currency is known, convert to dollars
            if !json[:details][:rent_price_currency].nil?
              currency_index = @currencies.keys.index(json[:details][:rent_price_currency].downcase)
              if !currency_index.nil?
                # exchange rate
                json[:details][:rent_price_exchange_rate_to_dollars] = @currencies.values[currency_index]

                # price
                if !json[:details][:rent_price].nil?
                  price = json[:details][:rent_price].to_f
                  json[:details][:rent_price_dollars] = price * @currencies.values[currency_index]
                end
                # price per sq meter
                if !json[:details][:rent_price_sq_meter].nil?
                  price = json[:details][:rent_price_sq_meter].to_f
                  json[:details][:rent_price_sq_meter_dollars] = price * @currencies.values[currency_index]
                end
              else
                @missing_param_log.error "Missing currency exchange #{json[:details][:sale_rent_currency]} in record #{id}"
              end
            end

          # if this is a square meter key, split the number and measurement
          elsif @sq_m_keys.include?(key)
            values = json[:details][key].split(' ')
            json[:details][key] = values[0].strip
            new_key = key.to_s + '_measurement'
            json[:details][new_key.to_sym] = values[1].strip if !values[1].nil?
          # if this is address, split it into its parts
          elsif @address_key == key
            address_parts = json[:details][key].split(',')
            if !address_parts[0].nil?
              json[:details][:address_city] = address_parts[0].strip
            end
            if !address_parts[1].nil?
              json[:details][:address_area] = address_parts[1].strip
            end
            if !address_parts[2].nil?
              json[:details][:address_district] = address_parts[2].strip
            end
            if !address_parts[3].nil?
              json[:details][:address_street] = address_parts[3].strip
            end
            if !address_parts[4].nil?
              json[:details][:address_number] = address_parts[4].strip
            end
          end
        end
      else
        @missing_param_log.error "Missing detail json key for text: '#{title_text}' in record #{id}"
      end
    end      
  end

  # spec info
  specs_titles = doc.css('span.dc_title')
  specs_values = doc.css('span.dc_title + span')
  if specs_titles.length > 0 && specs_values.length > 0
    specs_titles.each_with_index do |title, title_index|
      title_text = title.text.strip.downcase
      # get the index for the key with this text
      index = @locales[locale_key][:keys][:specs].values.index{|x| title_text == x}
      if index
        # get the key name for this text
        key = @locales[locale_key][:keys][:specs].keys[index]
        # save the value
        json[:specs][key] = specs_values[title_index].text.strip    
      else
        @missing_param_log.error "Missing spec json key for text: '#{title_text}' in record #{id}"
      end
    end
  end

  # additional info
  tables = nil
  if locale_key == :en
    tables = doc.css('table.fen')
  else
    tables = doc.css('table.fge')
  end
  if tables.length > 6
    tds = tables[5].css('td')
    if tds.length > 2
      # there may be many rows so grab them all
      # ignore first row for it is header
      tds.each_with_index do |td, index|
        # if this is not the additional info section, stop
        break if index == 0 && td.text.strip.downcase != @locales[locale_key][:keys][:additional_info]
        if index > 0
          text = td.text.strip 
          if text != @nbsp
            if json[:additional_info].nil?
              json[:additional_info] = text
            else
              json[:additional_info] += " \n #{text}"
            end
          end
        end
      end
    end
  end

  if !json[:posting_id].nil?
    # save the json
    file_path = folder_path + @json_file
    create_directory(File.dirname(file_path))
    File.open(file_path, 'w'){|f| f.write(json.to_json)}
  end
  
  # remove the id from the status list to indicate it was processed
  remove_status_json_id(id, locale_key.to_s)
end

##########################

def make_requests
  #initiate hydra
  hydra = Typhoeus::Hydra.new(max_concurrency: 20)
  request = nil

  # pull in first search results page
  url = @serach_url + @lang_param + @locales[:ka][:id]

  doc = Nokogiri::HTML(open(url))

  # get the number of pages of search results that exist
  # - get the p param out of the last page pagination link
  last_page = 50 # just give it a default value
  pagination_links = doc.css('.pagination a')
  if pagination_links.length > 0
    last_page = get_param_value(pagination_links[pagination_links.length-1]['href'], 'p')
  end
  last_page = last_page.to_i if !last_page.nil?  

  # get all of the ids that are new since the last run
  i = 1
  while !@found_all_ids && i <= last_page
    puts "page #{i}"
    # create the url
    url = @serach_url + @lang_param + @locales[:ka][:id] + @page_param + i.to_s
  
    # get the html
    doc = Nokogiri::HTML(open(url))
   
    # pull out the links for this page
    search_results = doc.css('td.table_content div.main_search div.ann_thmb a')

    # if the search results has either no response, stop
    if search_results.length == 0
      @log.error "the response does not have any content to process for url #{url}"
      break
    end
    
    # get the ids for this page
    pull_out_ids(search_results, i == 1)
    
    i+=1
  end

  num_ids = num_json_ids_to_process
  
  if num_ids == 0
    @log.warn "There are no new IDs to process so stopping"
    return
  end

  # record total number of records to process 
  total_to_process = num_ids
  total_left_to_process = num_ids

  #build hydra queue
  @locales.keys.each do |locale|
    # if there are any ids for this locale, procss them
    if @status['ids_to_process']['json'][locale.to_s].length > 0
      ids = @status['ids_to_process']['json'][locale.to_s].dup
      ids.each do |id|
        # build the url
        url = @posting_url + id + @lang_param + @locales[locale][:id]
        request = Typhoeus::Request.new("#{url}", followlocation: true)

        request.on_complete do |response|
          if response.success?
            # put success callback here
            @log.info("#{response.request.url} - success")
            
            # process the response        
            process_response(response)
          elsif response.timed_out?
            # aw hell no
            @log.warn("#{response.request.url} - got a time out")
          elsif response.code == 0
            # Could not get an http response, something's wrong.
            @log.error("#{response.request.url} - no response: #{response.return_message}")
          else
            # Received a non-successful http response.
            @log.error("#{response.request.url} - HTTP request failed: #{response.code.to_s}")
          end
          
          # decrease counter of items to process
          total_left_to_process -= 1
          if total_left_to_process == 0
            @log.info "------------------------------"
            @log.info "It took #{Time.now - @start} seconds to process #{total_to_process} items"
            @log.info "------------------------------"

            # now update the database
            update_database

            # now push to git
            update_github

          elsif total_left_to_process % 200 == 0
            puts "There are #{total_left_to_process} files left to process; time so far = #{Time.now - @start} seconds"
          end
        end
        hydra.queue(request)
      end
    end
  end

  hydra.run

end

# run the script
make_requests


