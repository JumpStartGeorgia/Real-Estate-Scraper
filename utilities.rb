#!/usr/bin/env ruby
# encoding: utf-8

require 'subexec'

# currenct exchange rates to dollar
@currencies = {}
@currencies['$'] = 1.00
@currencies['gel'] = 0.57 #1.75
@currencies['€'] = 1.38 #0.72

# the price for a place for rent and for sale include
# the price and the price per square meter
@sale_keys = [:for_sale, :for_lease]
@rent_keys = [:for_rent, :daily_rent]
@sq_m_keys = [:space, :land]
@address_key = :address

@non_number_price_text = ['Price Negotiable', 'ფასი შეთანხმებით']

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
@locales[:ka][:keys][:details][:est_lease_price] = 'სავარ. გაქ. ფასი'
@locales[:ka][:keys][:details][:space] = 'ფართობი'
@locales[:ka][:keys][:details][:land] = 'მიწა'
@locales[:ka][:keys][:details][:renovation] = 'რემონტი'
@locales[:ka][:keys][:details][:view] = 'ხედი'
@locales[:ka][:keys][:details][:project] = 'პროექტი'
@locales[:ka][:keys][:details][:condition] = 'მდგომარეობა'
@locales[:ka][:keys][:details][:function] = 'დანიშნულება'
@locales[:ka][:keys][:details][:address] = 'მისამართი'
@locales[:ka][:keys][:details][:phone] = 'ტელეფონი'
@locales[:ka][:keys][:details][:cadastral] = 'საკადასტრო'
@locales[:ka][:keys][:specs] = {}
@locales[:ka][:keys][:specs][:all_floors] = 'სართული სულ:'
@locales[:ka][:keys][:specs][:floor] = 'სართული:'
@locales[:ka][:keys][:specs][:rooms] = 'ოთახები:'
@locales[:ka][:keys][:specs][:bedrooms] = 'საძინებელი:'
@locales[:ka][:keys][:specs][:conference_room] = 'საკონფერენციო:'
@locales[:ka][:keys][:specs][:suites] = 'ლუქსი:'
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
@locales[:ka][:keys][:specs][:workroom] = 'საწარმოო შენობა (m²):'
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
@locales[:en][:keys][:details][:est_lease_price] = 'est. lease price'
@locales[:en][:keys][:details][:space] = 'space'
@locales[:en][:keys][:details][:land] = 'land'
@locales[:en][:keys][:details][:renovation] = 'renovation'
@locales[:en][:keys][:details][:view] = 'view'
@locales[:en][:keys][:details][:project] = 'project'
@locales[:en][:keys][:details][:condition] = 'condition'
@locales[:en][:keys][:details][:function] = 'function'
@locales[:en][:keys][:details][:address] = 'address'
@locales[:en][:keys][:details][:phone] = 'phone'
@locales[:en][:keys][:details][:cadastral] = 'cadastral'
@locales[:en][:keys][:specs] = {}
@locales[:en][:keys][:specs][:all_floors] = 'all floors:'
@locales[:en][:keys][:specs][:floor] = 'floor:'
@locales[:en][:keys][:specs][:rooms] = 'room(s):'
@locales[:en][:keys][:specs][:bedrooms] = 'bedroom(s):'
@locales[:en][:keys][:specs][:conference_room] = 'conference room:'
@locales[:en][:keys][:specs][:suites] = 'suites:'
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
  json[:details][:est_lease_price] = nil
  json[:details][:rent_price] = nil
  json[:details][:rent_price_currency] = nil
  json[:details][:rent_price_sq_meter] = nil
  json[:details][:rent_price_dollars] = nil
  json[:details][:rent_price_sq_meter_dollars] = nil
  json[:details][:rent_price_exchange_rate_to_dollars] = nil
  json[:details][:sale_price] = nil
  json[:details][:sale_price_currency] = nil
  json[:details][:sale_price_sq_meter] = nil
  json[:details][:sale_price_dollars] = nil
  json[:details][:sale_price_sq_meter_dollars] = nil
  json[:details][:sale_price_exchange_rate_to_dollars] = nil
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
  json[:details][:cadastral] = nil

  json[:specs] = {}
  json[:specs][:all_floors] = nil
  json[:specs][:floor] = nil
  json[:specs][:rooms] = nil
  json[:specs][:bedrooms] = nil
  json[:specs][:conference_room] = nil
  json[:specs][:suites] = nil
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

def create_directory(file_path)
	if !file_path.nil? && file_path != "."
		FileUtils.mkpath(file_path)
	end
end

# get the parent folder for the provided id
# - the folder is the id minus it's last 3 digits
def get_parent_id_folder(id)
  id.to_s[0..id.to_s.length-4]
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
    status['ids_to_process'] = {}
    ['json', 'db'].each do |key|
      status['ids_to_process'][key] = {}
      @locales.keys.each do |locale|
        status['ids_to_process'][key][locale.to_s] = []
      end
    end
    File.open(@status_file, 'w') { |f| f.write(status.to_json) }
  end
  return status
end

# determine if ther eare any json ids to process
def num_json_ids_to_process
  count = 0
  
  @locales.keys.each do |locale|
    count += @status['ids_to_process']['json'][locale.to_s].length
  end
  
  return count
end

def save_new_status_ids(ids)
  if !ids.nil? && ids.length > 0
    ['json', 'db'].each do |key|
      @locales.keys.each do |locale|
        @status['ids_to_process'][key][locale.to_s] << ids
        @status['ids_to_process'][key][locale.to_s].flatten!
      end
    end
    update_status  
  end
end

def remove_status_json_id(id, locale)
  @status['ids_to_process']['json'][locale.to_s].delete(id)
  update_status
end

def remove_status_db_id(id, locale)
  @status['ids_to_process']['db'][locale.to_s].delete(id)
  update_status
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

  save_new_status_ids(ids) if ids.length > 0
end


# create sql for insert statements
def create_sql_insert(mysql, json, source, locale)
  fields = []
  values = []
  sql = nil
  
  fields << 'source'
  values << source

  fields << 'locale'
  values << locale
  
  fields << 'created_at'
  values << Time.now

  if !json["posting_id"].nil?
    fields << 'posting_id'
    values << json["posting_id"]
  end
  if !json["type"].nil?
    fields << 'type'
    values << json["type"]
  end
  if !json["property_type"].nil?
    fields << 'property_type'
    values << json["property_type"]
  end
  if !json["date"].nil?
    fields << 'date'
    values << json["date"]
  end
  if !json["additional_info"].nil?
    fields << 'additional_info'
    values << json["additional_info"]
  end

  if !json["details"]["daily_rent"].nil?
    fields << 'daily_rent'
    values << json["details"]["daily_rent"]
  end
  if !json["details"]["for_rent"].nil?
    fields << 'for_rent'
    values << json["details"]["for_rent"]
  end
  if !json["details"]["for_sale"].nil?
    fields << 'for_sale'
    values << json["details"]["for_sale"]
  end
  if !json["details"]["for_lease"].nil?
    fields << 'for_lease'
    values << json["details"]["for_lease"]
  end
  if !json["details"]["est_lease_price"].nil?
    fields << 'est_lease_price'
    values << json["details"]["est_lease_price"]
  end
  if !json["details"]["rent_price"].nil?
    fields << 'rent_price'
    values << json["details"]["rent_price"]
  end
  if !json["details"]["rent_price_currency"].nil?
    fields << 'rent_price_currency'
    values << json["details"]["rent_price_currency"]
  end
  if !json["details"]["rent_price_exchange_rate_to_dollars"].nil?
    fields << 'rent_price_exchange_rate_to_dollars'
    values << json["details"]["rent_price_exchange_rate_to_dollars"]
  end
  if !json["details"]["rent_price_dollars"].nil?
    fields << 'rent_price_dollars'
    values << json["details"]["rent_price_dollars"]
  end
  if !json["details"]["rent_price_sq_meter"].nil?
    fields << 'rent_price_sq_meter'
    values << json["details"]["rent_price_sq_meter"]
  end
  if !json["details"]["rent_price_sq_meter_dollars"].nil?
    fields << 'rent_price_sq_meter_dollars'
    values << json["details"]["rent_price_sq_meter_dollars"]
  end
  if !json["details"]["sale_price"].nil?
    fields << 'sale_price'
    values << json["details"]["sale_price"]
  end
  if !json["details"]["sale_price_currency"].nil?
    fields << 'sale_price_currency'
    values << json["details"]["sale_price_currency"]
  end
  if !json["details"]["sale_price_exchange_rate_to_dollars"].nil?
    fields << 'sale_price_exchange_rate_to_dollars'
    values << json["details"]["sale_price_exchange_rate_to_dollars"]
  end
  if !json["details"]["sale_price_dollars"].nil?
    fields << 'sale_price_dollars'
    values << json["details"]["sale_price_dollars"]
  end
  if !json["details"]["sale_price_sq_meter"].nil?
    fields << 'sale_price_sq_meter'
    values << json["details"]["sale_price_sq_meter"]
  end
  if !json["details"]["sale_price_sq_meter_dollars"].nil?
    fields << 'sale_price_sq_meter_dollars'
    values << json["details"]["sale_price_sq_meter_dollars"]
  end
  if !json["details"]["space"].nil?
    fields << 'space'
    values << json["details"]["space"]
  end
  if !json["details"]["space_measurement"].nil?
    fields << 'space_measurement'
    values << json["details"]["space_measurement"]
  end
  if !json["details"]["land"].nil?
    fields << 'land'
    values << json["details"]["land"]
  end
  if !json["details"]["land_measurement"].nil?
    fields << 'land_measurement'
    values << json["details"]["land_measurement"]
  end
  if !json["details"]["renovation"].nil?
    fields << 'renovation'
    values << json["details"]["renovation"]
  end
  if !json["details"]["view"].nil?
    fields << 'view'
    values << json["details"]["view"]
  end
  if !json["details"]["project"].nil?
    fields << 'project'
    values << json["details"]["project"]
  end
  if !json["details"]["condition"].nil?
    fields << 'place_condition'
    values << json["details"]["condition"]
  end
  if !json["details"]["function"].nil?
    fields << 'function'
    values << json["details"]["function"]
  end
  if !json["details"]["address"].nil?
    fields << 'address'
    values << json["details"]["address"]
  end
  if !json["details"]["address_city"].nil?
    fields << 'address_city'
    values << json["details"]["address_city"]
  end
  if !json["details"]["address_area"].nil?
    fields << 'address_area'
    values << json["details"]["address_area"]
  end
  if !json["details"]["address_district"].nil?
    fields << 'address_district'
    values << json["details"]["address_district"]
  end
  if !json["details"]["address_street"].nil?
    fields << 'address_street'
    values << json["details"]["address_street"]
  end
  if !json["details"]["address_number"].nil?
    fields << 'address_number'
    values << json["details"]["address_number"]
  end
  if !json["details"]["phone"].nil?
    fields << 'phone'
    values << json["details"]["phone"]
  end
  if !json["details"]["cadastral"].nil?
    fields << 'cadastral'
    values << json["details"]["cadastral"]
  end

  if !json["specs"]["all_floors"].nil?
    fields << 'all_floors'
    values << json["specs"]["all_floors"]
  end
  if !json["specs"]["floor"].nil?
    fields << 'floor'
    values << json["specs"]["floor"]
  end
  if !json["specs"]["rooms"].nil?
    fields << 'rooms'
    values << json["specs"]["rooms"]
  end
  if !json["specs"]["bedrooms"].nil?
    fields << 'bedrooms'
    values << json["specs"]["bedrooms"]
  end
  if !json["specs"]["conference_room"].nil?
    fields << 'conference_room'
    values << json["specs"]["conference_room"]
  end
  if !json["specs"]["suites"].nil?
    fields << 'suites'
    values << json["specs"]["suites"]
  end
  if !json["specs"]["wc"].nil?
    fields << 'wc'
    values << json["specs"]["wc"]
  end
  if !json["specs"]["bathroom"].nil?
    fields << 'bathroom'
    values << json["specs"]["bathroom"]
  end
  if !json["specs"]["shower"].nil?
    fields << 'shower'
    values << json["specs"]["shower"]
  end
  if !json["specs"]["fireplace"].nil?
    fields << 'fireplace'
    values << json["specs"]["fireplace"]
  end
  if !json["specs"]["air_conditioner"].nil?
    fields << 'air_conditioner'
    values << json["specs"]["air_conditioner"]
  end
  if !json["specs"]["balcony"].nil?
    fields << 'balcony'
    values << json["specs"]["balcony"]
  end
  if !json["specs"]["veranda"].nil?
    fields << 'veranda'
    values << json["specs"]["veranda"]
  end
  if !json["specs"]["loft"].nil?
    fields << 'loft'
    values << json["specs"]["loft"]
  end
  if !json["specs"]["bodrum"].nil?
    fields << 'bodrum'
    values << json["specs"]["bodrum"]
  end
  if !json["specs"]["mansard"].nil?
    fields << 'mansard'
    values << json["specs"]["mansard"]
  end
  if !json["specs"]["parking"].nil?
    fields << 'parking'
    values << json["specs"]["parking"]
  end
  if !json["specs"]["garage"].nil?
    fields << 'garage'
    values << json["specs"]["garage"]
  end
  if !json["specs"]["dist_from_tbilisi"].nil?
    fields << 'dist_from_tbilisi'
    values << json["specs"]["dist_from_tbilisi"]
  end
  if !json["specs"]["dist_from_cent_street"].nil?
    fields << 'dist_from_cent_street'
    values << json["specs"]["dist_from_cent_street"]
  end
  if !json["specs"]["box"].nil?
    fields << 'box'
    values << json["specs"]["box"]
  end
  if !json["specs"]["buildings"].nil?
    fields << 'buildings'
    values << json["specs"]["buildings"]
  end
  if !json["specs"]["administration_building"].nil?
    fields << 'administration_building'
    values << json["specs"]["administration_building"]
  end
  if !json["specs"]["workroom"].nil?
    fields << 'workroom'
    values << json["specs"]["workroom"]
  end
  if !json["specs"]["stockroom"].nil?
    fields << 'stockroom'
    values << json["specs"]["stockroom"]
  end
  if !json["specs"]["coefficient_k1"].nil?
    fields << 'coefficient_k1'
    values << json["specs"]["coefficient_k1"]
  end
  if !json["specs"]["coefficient_k2"].nil?
    fields << 'coefficient_k2'
    values << json["specs"]["coefficient_k2"]
  end

  if !fields.empty? && !values.empty?
    sql= "insert into postings("
    sql << fields.join(', ')
    sql << ") values("
    sql << values.map{|x| "\"#{mysql.escape(x.to_s)}\""}.join(', ')
    sql << ")"
  end
  
  return sql
end

# delete the record if it already exists
def delete_record_sql(mysql, posting_id, locale)
    sql = "delete from postings where posting_id = '"
    sql << mysql.escape(posting_id.to_s)
    sql << "' and locale = '"
    sql << mysql.escape(locale.to_s)
    sql << "'"

    return sql
end

# dump the database
def dump_database(db_config, log)
  log.info "------------------------------"
  log.info "dumping database"
  log.info "------------------------------"
  Subexec.run "mysqldump -u'#{db_config["username"]}' -p'#{db_config["password"]}' #{db_config["database"]} | gzip > \"#{db_config["database"]}.sql.gz\" "
end


# update github with any changes
def update_github
  @log.info "------------------------------"
  @log.info "updating git"
  @log.info "------------------------------"
  x = Subexec.run "git add -A"
  x = Subexec.run "git commit -am 'Automated new jobs collected on #{Time.now.strftime('%F')}'"
  x = Subexec.run "git push origin master"
end
