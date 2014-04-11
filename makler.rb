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

@log.info "**********************************************"
@log.info "**********************************************"


# starting url 
@view_url = "http://makler.ge/?pg=ann&id="
@serach_url = "http://makler.ge/?pg=search&cat=-1&tp=-1&city_id=-1&raion_id=0&price_f=&price_t=&valuta=2&sart_f=&sart_t=&rooms_f=&rooms_t=&ubani_id=0&street_id=0&parti_f=&parti_t=&mdgomareoba=0&remont=0&project=0&xedi=0&metro_id=0&is_detailed_search=2&sb=d"
@page_param = "&p="
@lang_param = "&lan="


####################################################


# process the response
def process_response(response)
  # pull out the locale and id from the url
  id = get_param_value(response.request.url, 'id')
  locale = get_param_value(response.request.url, 'lan')
  if id.nil? || locale.nil?
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
    
    
    
    # get the type/id/date
    header_row = doc.css('.div_for_content > .page_title')
    if header_row.length > 0
      type_text = header_row.css('span')[0].xpath('text()').text.strip
      json[:type] = get_page_type(type_text, locale).to_s

      json[:id] = header_row.css('span')[2].xpath('text()').text.strip

      json[:date] = header_row.css('span')[header_row.css('span').length-1].xpath('text()').text.strip.gsub('.', '/')
      
    end
    
    puts json
    
    
=begin    
    # create the json
    json = json_template
    
    # general info
    general_title = doc.css('#content-main #general_info li.title')
    general_lists = doc.css('#content-main #general_info li.info')
    if general_title.length > 0 && general_lists.length > 0
      json[:general].keys.each do |key|
        index = general_title.to_a.index{|x| x.text.strip.downcase == @keys[locale.to_sym][:general][key]}
        if index
          json[:general][key] = general_lists[index].text.strip    
        end      
      end      
    end

    # job description
    descriptions = doc.css('#content-main #job_description p')
    if descriptions.length > 0
      json[:job_description] = descriptions[0].text.strip
      json[:additional_requirements] = descriptions[1].text.strip if descriptions.length > 1
      json[:additional_info] = descriptions[2].text.strip if descriptions.length > 2
    end

    # contact info
    contacts_title = doc.css('#content-main #contact_info li.title')
    contacts = doc.css('#content-main #contact_info li.info')
    if contacts_title.length > 0 && contacts.length > 0
      json[:contact].keys.each do |key|
        index = contacts_title.to_a.index{|x| x.text.strip.downcase == @keys[locale.to_sym][:contact][key]}
        if index
          json[:contact][key] = contacts[index].text.strip    
        end      
      end      
    end
    
    # qualifications
    qualifications_title = doc.css('#content-main #qualifications li.title')
    qualifications = doc.css('#content-main #qualifications li.info')
    if qualifications_title.length > 0 && qualifications.length > 0
      json[:qualifications].keys.each do |key|
        index = qualifications_title.to_a.index{|x| x.text.strip.downcase == @keys[locale.to_sym][:qualifications][key]}
        if index
          json[:qualifications][key] = qualifications[index].text.strip    
        end      
      end      
    end    

    # computers
    computers = doc.css('#content-main #computer table tr')
    if computers.length > 0
      computers.each_with_index do |computer, index|
        if index > 0
          h = {}
          tds = computer.css('td')
          if tds.length > 0
            h[:program] = tds[0].text.strip
            h[:knowledge] = tds[1].text.strip
            json[:computers] << h            
          end
        end
      end
    end

    # languages
    languages = doc.css('#content-main #languages table tr')
    if languages.length > 0
      languages.each_with_index do |language, index|
        if index > 0
          h = {}
          tds = language.css('td')
          if tds.length > 0
            h[:language] = tds[0].text.strip
            h[:writing] = tds[1].text.strip
            h[:reading] = tds[2].text.strip
            json[:languages] << h            
          end
        end
      end
    end

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

