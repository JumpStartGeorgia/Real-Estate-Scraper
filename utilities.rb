#!/usr/bin/env ruby
# encoding: utf-8

# file paths
@data_path = 'data/makler.ge/'
@response_file = 'response.html'
@json_file = 'data.json'
@db_config_path = 'database.yml'
@status_file = 'status.json'

# which languages to process
# georgian
@locales = {}
@locales[:ka] = {}
@locales[:ka][:locale] = 'geo'
@locales[:ka][:id] = '1'
@locales[:ka][:types] = {}
@locales[:ka][:types][:sale] = 'იყიდება'
@locales[:ka][:types][:rent] = 'ქირავდება'
@locales[:ka][:types][:lease] = 'გირავდება'
@locales[:ka][:types][:daily_rent] = 'დღიური გაქ.'
@locales[:ka][:property_types] = {}
@locales[:ka][:property_types][:apartment] = 'ბინა'
@locales[:ka][:property_types][:private_house] = 'საკუთარი სახლი'
@locales[:ka][:property_types][:office] = 'ოფისი'
@locales[:ka][:property_types][:commerical_space] = 'კომერციული ფართი'
@locales[:ka][:property_types][:country_house] = 'აგარაკი'
@locales[:ka][:property_types][:land] = 'მიწა'
@locales[:ka][:keys] = {}
@locales[:ka][:keys][:details] = {}
@locales[:ka][:keys][:details][:daily_rent] = 'დღიური გაქ.'
@locales[:ka][:keys][:details][:for_sale] = 'იყიდება'
@locales[:ka][:keys][:details][:for_rent] = 'ქირავდება'
@locales[:ka][:keys][:details][:for_lease] = 'გირავდება'
@locales[:ka][:keys][:details][:space] = 'ფართობი'
@locales[:ka][:keys][:details][:land] = 'მიწა'
@locales[:ka][:keys][:details][:renovation] = 'რემონტი'
@locales[:ka][:keys][:details][:view] = 'ხედი'
@locales[:ka][:keys][:details][:project] = 'პროექტი'
@locales[:ka][:keys][:details][:condition] = 'მდგომარეობა'
@locales[:ka][:keys][:details][:function] = 'დანიშნულება'
@locales[:ka][:keys][:details][:address] = 'მისამართი'
@locales[:ka][:keys][:details][:phone] = 'ტელეფონი'
@locales[:ka][:keys][:specs] = {}
@locales[:ka][:keys][:specs][:all_floors] = 'სართული სულ:'
@locales[:ka][:keys][:specs][:floor] = 'სართული:'
@locales[:ka][:keys][:specs][:rooms] = 'ოთახები:'
@locales[:ka][:keys][:specs][:bedrooms] = 'საძინებელი:'
@locales[:ka][:keys][:specs][:conference_room] = 'საკონფერენციო:'
@locales[:ka][:keys][:specs][:wc] = 'სველი წერტილი:'
@locales[:ka][:keys][:specs][:bathroom] = 'აბაზანა:'
@locales[:ka][:keys][:specs][:shower] = 'საშხაპე:'
@locales[:ka][:keys][:specs][:fireplace] = 'ბუხარი:'
@locales[:ka][:keys][:specs][:air_conditioner] = 'კონდიციონერი:'
@locales[:ka][:keys][:specs][:balcony] = 'აივანი:'
@locales[:ka][:keys][:specs][:veranda] = 'ვერანდა (m²):'
@locales[:ka][:keys][:specs][:loft] = 'სხვენი (m²):'
@locales[:ka][:keys][:specs][:bodrum] = 'სარდაფი (m²):'
@locales[:ka][:keys][:specs][:mansard] = 'მანსარდა (m²):'
@locales[:ka][:keys][:specs][:parking] = 'პარკინგი:'
@locales[:ka][:keys][:specs][:garage] = 'ავტოფარეხი:'
@locales[:ka][:keys][:specs][:dist_from_tbilisi]= 'დაშორება თბილისიდან:'
@locales[:ka][:keys][:specs][:dist_from_cent_street] = 'დაშორება ცენტ. გზიდან:'
@locales[:ka][:keys][:specs][:box] = 'ბოქსი:'
@locales[:ka][:keys][:specs][:buildings] = 'შენობა-ნაგებობა:'
@locales[:ka][:keys][:specs][:administration_building] = 'ადმინისტ. შენობა (m²):'
@locales[:ka][:keys][:specs][:workroom] = 'საწარმოო შენობ (m²):'
@locales[:ka][:keys][:specs][:stockroom] = 'სასაწყობე ფართი (m²):'
@locales[:ka][:keys][:specs][:coefficient_k1] = 'კოეფიციენტი k1:'
@locales[:ka][:keys][:specs][:coefficient_k2] = 'კოეფიციენტი k2:'
@locales[:ka][:keys][:additional_info]  = 'დამატებითი ინფორმაცია'

# english
@locales[:en] = {}
@locales[:en][:locale] = 'eng'
@locales[:en][:id] = '2'
@locales[:en][:types] = {}
@locales[:en][:types][:sale] = 'for sale'
@locales[:en][:types][:rent] = 'for rent'
@locales[:en][:types][:lease] = 'for lease'
@locales[:en][:types][:daily_rent] = 'daily rent'
@locales[:en][:property_types] = {}
@locales[:en][:property_types][:apartment] = 'apartment'
@locales[:en][:property_types][:private_house] = 'private house'
@locales[:en][:property_types][:office] = 'office'
@locales[:en][:property_types][:commerical_space] = 'commercial space'
@locales[:en][:property_types][:country_house] = 'country house'
@locales[:en][:property_types][:land] = 'land'
@locales[:en][:keys] = {}
@locales[:en][:keys][:details] = {}
@locales[:en][:keys][:details][:daily_rent] = 'daily rent'
@locales[:en][:keys][:details][:for_sale] = 'for sale'
@locales[:en][:keys][:details][:for_rent] = 'for rent'
@locales[:en][:keys][:details][:for_lease] = 'for lease'
@locales[:en][:keys][:details][:space] = 'space'
@locales[:en][:keys][:details][:land] = 'land'
@locales[:en][:keys][:details][:renovation] = 'renovation'
@locales[:en][:keys][:details][:view] = 'view'
@locales[:en][:keys][:details][:project] = 'project'
@locales[:en][:keys][:details][:condition] = 'condition'
@locales[:en][:keys][:details][:function] = 'function'
@locales[:en][:keys][:details][:address] = 'address'
@locales[:en][:keys][:details][:phone] = 'phone'
@locales[:en][:keys][:specs] = {}
@locales[:en][:keys][:specs][:all_floors] = 'all floors:'
@locales[:en][:keys][:specs][:floor] = 'floor:'
@locales[:en][:keys][:specs][:rooms] = 'room(s):'
@locales[:en][:keys][:specs][:bedrooms] = 'bedroom(s):'
@locales[:en][:keys][:specs][:conference_room] = 'conference room:'
@locales[:en][:keys][:specs][:wc] = 'wc:'
@locales[:en][:keys][:specs][:bathroom] = 'bathroom:'
@locales[:en][:keys][:specs][:shower] = 'shower:'
@locales[:en][:keys][:specs][:fireplace] = 'fireplace:'
@locales[:en][:keys][:specs][:air_conditioner] = 'air-conditioner:'
@locales[:en][:keys][:specs][:balcony] = 'balcony:'
@locales[:en][:keys][:specs][:veranda] = 'veranda (m²):'
@locales[:en][:keys][:specs][:loft] = 'loft (m²):'
@locales[:en][:keys][:specs][:bodrum] = 'bodrum (m²):'
@locales[:en][:keys][:specs][:mansard] = 'mansard (m²):'
@locales[:en][:keys][:specs][:parking] = 'parking:'
@locales[:en][:keys][:specs][:garage] = 'garage:'
@locales[:en][:keys][:specs][:dist_from_tbilisi]= 'distance from tbilisi:'
@locales[:en][:keys][:specs][:dist_from_cent_street] = 'distance from cent. street:'
@locales[:en][:keys][:specs][:box] = 'box:'
@locales[:en][:keys][:specs][:buildings] = 'buildings:'
@locales[:en][:keys][:specs][:administration_building] = 'administ. building (m²):'
@locales[:en][:keys][:specs][:workroom] = 'workroom (m²):'
@locales[:en][:keys][:specs][:stockroom] = 'stockroom (m²):'
@locales[:en][:keys][:specs][:coefficient_k1] = 'coefficient k1:'
@locales[:en][:keys][:specs][:coefficient_k2] = 'coefficient k2:'
@locales[:en][:keys][:additional_info]  = 'additional information'

# the price for a place for rent and for sale include
# the price and the price per square meter
@sale_keys = [:for_sale, :for_lease]
@rent_keys = [:for_rent, :daily_rent]
@sq_m_keys = [:space, :land]
@address_key = :address


def json_template
  json = {}
  json[:posting_id] = nil
  json[:locale] = nil
  json[:type] = nil
  json[:property_type] = nil
  json[:date] = nil
  json[:additional_info] = nil
  
  json[:details] = {}
  json[:details][:daily_rent] = nil
  json[:details][:for_rent] = nil
  json[:details][:for_sale] = nil
  json[:details][:for_lease] = nil
  json[:details][:rent_price] = nil
  json[:details][:rent_price_currency] = nil
  json[:details][:rent_price_exchange_rate] = 1
  json[:details][:rent_price_sq_meter] = nil
  json[:details][:sale_price] = nil
  json[:details][:sale_price_currency] = nil
  json[:details][:sale_price_exchange_rate] = 1
  json[:details][:sale_price_sq_meter] = nil
  json[:details][:space] = nil
  json[:details][:space_measurement] = nil
  json[:details][:land] = nil
  json[:details][:land_measurement] = nil
  json[:details][:renovation] = nil
  json[:details][:view] = nil
  json[:details][:project] = nil
  json[:details][:condition] = nil
  json[:details][:function] = nil
  json[:details][:address] = nil
  json[:details][:address_city] = nil
  json[:details][:address_area] = nil
  json[:details][:address_district] = nil
  json[:details][:address_street] = nil
  json[:details][:address_number] = nil
  json[:details][:phone] = nil

  json[:specs] = {}
  json[:specs][:all_floors] = nil
  json[:specs][:floor] = nil
  json[:specs][:rooms] = nil
  json[:specs][:bedrooms] = nil
  json[:specs][:conference_room] = nil
  json[:specs][:wc] = nil
  json[:specs][:bathroom] = nil
  json[:specs][:shower] = nil
  json[:specs][:fireplace] = nil
  json[:specs][:air_conditioner] = nil
  json[:specs][:balcony] = nil
  json[:specs][:veranda] = nil
  json[:specs][:loft] = nil
  json[:specs][:bodrum] = nil
  json[:specs][:mansard] = nil
  json[:specs][:parking] = nil
  json[:specs][:garage] = nil
  json[:specs][:dist_from_tbilisi]= nil
  json[:specs][:dist_from_cent_street] = nil
  json[:specs][:box] = nil
  json[:specs][:buildings] = nil
  json[:specs][:administration_building] = nil
  json[:specs][:workroom] = nil
  json[:specs][:stockroom] = nil
  json[:specs][:coefficient_k1] = nil
  json[:specs][:coefficient_k2] = nil

  return json
end



def get_locale_key(locale_id)
  match = @locales.keys.select{|x| @locales[x][:id] == locale_id}.first
  if !match.nil?
    return match
  end
end

# determine the type of page being viewed
def get_page_type(text, locale_id)
  key = get_locale_key(locale_id)
  if !key.nil?  
    type = @locales[key][:types].values.select{|x| text.downcase.index(x) == 0}
    if !type.nil?
      return type.first
    end
  end
end

# determine the property type of page being viewed
def get_property_type(text, locale_id)
  key = get_locale_key(locale_id)
  if !key.nil?  
    type = @locales[key][:property_types].values.select{|x| !text.downcase.index(x).nil?}
    if !type.nil?
      return type.first
    end
  end
end

# pull out a query parameter value for a particular key
def get_param_value(url, key)
  value = nil
  index_q = url.index('?')
  if !index_q.nil?
    url_params = url.split('?').last
    
    if !url_params.nil?
      params = url_params.split('&')
    
      if !params.nil?
        param = params.select{|x| x.index(key + '=') == 0}
        if !param.nil?
          value = param.first.split('=')[1]
        end
      
      end
    end
  end

  return value
end

def get_status
  status = nil
  if File.exists? @status_file
    status = JSON.parse(File.read(@status_file))
  else
    status = {}
    status['last_id_processed'] = []
    File.open(@status_file, 'w') { |f| f.write(status.to_json) }
  end
  return status
end

def update_status
  @status = get_status if @status.nil?
  if File.exists? @status_file
    File.open(@status_file, 'w') { |f| f.write(@status.to_json) }
  end
end

# pull out the id of each property from the link
def pull_out_ids(search_results, record_last_id_status=false)
  ids = []
  recorded_first_id = false
  search_results.each_with_index do |search_result, index|
    id = get_param_value(search_result['href'], 'id')
    if !id.nil?
      if !recorded_first_id 
        # if this is a new id, update the status
        # else, stop for we found the id of one that is already processed
        if @status['last_id_processed'].last == id
          @log.info "Found the smae id as the last id processed, so stopping"
          @found_all_ids = true
          break
        elsif record_last_id_status
          @status['last_id_processed'] << id
          update_status
        end
        recorded_first_id = true
      end
      # if we find the id that was process during the last run, stop
      # for we have found all of the new ids
      if @status['last_id_processed'].length > 1 && 
            id == @status['last_id_processed'][@status['last_id_processed'].length-2]

        @found_all_ids = true
        break
      end
      ids << id
    end
  end  

  return ids
end
