#!/usr/bin/env ruby
# encoding: utf-8


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
@locales[:ka][:keys] = {}
@locales[:ka][:keys][:details] = {}
@locales[:ka][:keys][:details][:daily_rent] = 'დღიური გაქ.'
@locales[:ka][:keys][:details][:for_sale] = 'იყიდება'
@locales[:ka][:keys][:details][:for_rent] = 'ქირავდება'
@locales[:ka][:keys][:details][:space] = 'ფართობი'
@locales[:ka][:keys][:details][:land] = 'მიწა'
@locales[:ka][:keys][:details][:renovation] = 'რემონტი'
@locales[:ka][:keys][:details][:view] = 'ხედი'
@locales[:ka][:keys][:details][:project] = 'პროექტი'
@locales[:ka][:keys][:details][:condition] = 'მდგომარეობა'
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
@locales[:ka][:keys][:specs][:stockroom] = 'სასაწყობე ფართი (m²):'
@locales[:ka][:keys][:specs][:bodrum] = 'სარდაფი (m²):'
@locales[:ka][:keys][:specs][:parking] = 'პარკინგი:'
@locales[:ka][:keys][:specs][:garage] = 'ავტოფარეხი:'

# english
@locales[:en] = {}
@locales[:en][:locale] = 'eng'
@locales[:en][:id] = '2'
@locales[:en][:types] = {}
@locales[:en][:types][:sale] = 'for sale'
@locales[:en][:types][:rent] = 'for rent'
@locales[:en][:types][:lease] = 'for lease'
@locales[:en][:types][:daily_rent] = 'daily rent'
@locales[:en][:keys] = {}
@locales[:en][:keys][:details] = {}
@locales[:en][:keys][:details][:daily_rent] = 'daily rent'
@locales[:en][:keys][:details][:for_sale] = 'for sale'
@locales[:en][:keys][:details][:for_rent] = 'for rent'
@locales[:en][:keys][:details][:space] = 'space'
@locales[:en][:keys][:details][:land] = 'land'
@locales[:en][:keys][:details][:renovation] = 'renovation'
@locales[:en][:keys][:details][:view] = 'view'
@locales[:en][:keys][:details][:project] = 'project'
@locales[:en][:keys][:details][:condition] = 'condition'
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
@locales[:en][:keys][:specs][:stockroom] = 'stockroom (m²):'
@locales[:en][:keys][:specs][:bodrum] = 'bodrum (m²):'
@locales[:en][:keys][:specs][:parking] = 'parking:'
@locales[:en][:keys][:specs][:garage] = 'garage:'


def json_template
  json = {}
  json[:type] = nil
  json[:id] = nil
  json[:date] = nil
  json[:additional_info] = nil
  
  json[:details] = {}
  json[:details][:daily_rent] = nil
  json[:details][:for_sale] = nil
  json[:details][:for_rent] = nil
  json[:details][:space] = nil
  json[:details][:land] = nil
  json[:details][:renovation] = nil
  json[:details][:view] = nil
  json[:details][:project] = nil
  json[:details][:condition] = nil
  json[:details][:address] = nil
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
  json[:specs][:stockroom] = nil
  json[:specs][:bodrum] = nil
  json[:specs][:parking] = nil
  json[:specs][:garage] = nil

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
    type_index = @locales[key][:types].values.index{|x| text.downcase.index(x) == 0}
    if !type_index.nil?
      return @locales[key][:types].keys[type_index]
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
