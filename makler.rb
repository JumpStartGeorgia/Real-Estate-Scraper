#!/usr/bin/env ruby
# encoding: utf-8

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


@start = Time.now

# log file to record messages
# delete existing log file
@log = Logger.new('makler.log')
@missing_param_log = Logger.new('makler_missing_params.log')

@log.info "**********************************************"
@log.info "**********************************************"


# starting url 
@view_url = "http://makler.ge/?pg=ann&id="
@serach_url = "http://makler.ge/?pg=search&cat=-1&tp=-1&city_id=-1&raion_id=0&price_f=&price_t=&valuta=2&sart_f=&sart_t=&rooms_f=&rooms_t=&ubani_id=0&street_id=0&parti_f=&parti_t=&mdgomareoba=0&remont=0&project=0&xedi=0&metro_id=0&is_detailed_search=2&sb=d"
@page_param = "&p="
@lang_param = "&lan="


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
    @log.error "response url is not in expected format: #{response.request.url}; expected url.split('/') to have length of 8 but has length of #{params.length}"
    return
  end
=begin
  # get the name of the folder for this id
  # - the name is the id minus it's last 2 digits
  id_folder = id[0..id.length-3]
  folder_path = @data_path + id_folder + "/" + id + "/" + locale + "/"
=end
  @log.info "processing response for id #{id} and locale #{locale}"

  # get the response body
  doc = Nokogiri::HTML(response.body)
    
=begin
  
    # save the response body
    file_path = folder_path + @response_file
		create_directory(File.dirname(file_path))
    File.open(file_path, 'w'){|f| f.write(doc)}
=end    
    if doc.css('td.table_content').length != 2
      @log.error "the response does not have any content to process"
      return
    end
    
    # create the json
    json = json_template
    
    json[:id] = id
    json[:locale] = locale_key.to_s
    
    # get the type/date
    header_row = doc.css('.div_for_content > .page_title')
    if header_row.length > 0
      type_text = header_row.css('span')[0].xpath('text()').text.strip
      json[:type] = get_page_type(type_text, locale).to_s
      json[:property_type] = get_property_type(type_text, locale).to_s

      json[:date] = header_row.css('span')[header_row.css('span').length-1].xpath('text()').text.strip.gsub('.', '/')
      
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
          
          # if this is a sale price, pull out the price and price per sq meter
          if @sale_keys.include?(key)
            prices = details_values[title_index].text.strip.split('/')
            price_ary = prices[0].strip.split(' ')
            
            json[:details][:sale_price] = price_ary[0].strip
            json[:details][:sale_price_currency] = price_ary[1].strip

            # if price per sq meter present, save it
            if prices.length > 1
              json[:details][:sale_price_sq_meter] = prices[1].strip.split(' ')[0].strip
            end
          # if this is a rent price, pull out the price and price per sq meter
          elsif @rent_keys.include?(key)
            prices = details_values[title_index].text.strip.split('/')
            price_ary = prices[0].strip.split(' ')
            
            json[:details][:rent_price] = price_ary[0].strip
            json[:details][:rent_price_currency] = price_ary[1].strip

            # if price per sq meter present, save it
            if prices.length > 1
              json[:details][:rent_price_sq_meter] = prices[1].strip.split(' ')[0].strip
            end
          # if this is a square meter key, split the number and measurement
          elsif @sq_m_keys.include?(key)
            values = details_values[title_index].text.strip.split(' ')
            json[:details][key] = values[0].strip
            new_key = key.to_s + '_measurement'
            json[:details][new_key.to_sym] = values[1].strip
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


    puts json
=begin
    # save the json
    file_path = folder_path + @json_file
		create_directory(File.dirname(file_path))
    File.open(file_path, 'w'){|f| f.write(json.to_json)}
  else
    @log.error "response url is not in expected format: #{response.request.url}; expected url.split('/') to have length of 8 but has length of #{params.length}"
  end
=end  
end

##########################

def make_requests
  # store id of url to call
  ids = []

  #initiate hydra
  hydra = Typhoeus::Hydra.new(max_concurrency: 20)
  request = nil

  # pull in first search results page
  url = @serach_url + @lang_param + '1'
  doc = Nokogiri::HTML(open(url))

  search_results = doc.css('td.table_content div.main_search div.ann_thmb a')

  # if the search results has either no response, stop
  if search_results.length == 0
    @log.error "the response does not have any content to process"
    return
  end
  
  # pull out the id of each property from the link
  search_results.each do |search_result|
    id = get_param_value(search_result['href'], 'id')
    if !id.nil?
      ids << id
    end
  end  

  if ids.length == 0
    @log.error "There are no search result IDs at this url to process (#{url})"
    return
  end
ids = ['4157276']
  # record total number of records to process 
  total_to_process = ids.length * @locales.keys.length
  total_left_to_process = ids.length * @locales.keys.length

  #build hydra queue
  ids.each do |id|
    @locales.keys.each do |locale|
      # build the url
      url = @view_url + id + @lang_param + @locales[locale][:id]
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
        end
      end


      hydra.queue(request)
    end
  end

  hydra.run
    
end

make_requests

