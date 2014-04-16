#!/usr/bin/env ruby
# encoding: utf-8

####################################################
# to load the jobs to a database, please have the following:
# - database.yml file with the following keys and the appropriate values
# - the user must have the ability to create database and tables
# - this database.yml file is not saved into the git repository so
#   passwords are not shared with the world
# - yml keys:
#     database: 
#     username: 
#     password: 
#     encoding: utf8
#     host: localhost
#     port: 3306
#     reconnect: true

# - you will need to create the database
# - the tables will be created if they do not exist
####################################################

require 'mysql2'
require 'yaml'
require 'logger'
require 'json'


require_relative 'utilities'


def update_database
  source = 'makler.ge'

  start = Time.now

  # log file to record messages
  # delete existing log file
  #File.delete('hr.gov.ge.log') if File.exists?('hr.gov.ge.log')
  log = Logger.new('database.log')

  log.info "**********************************************"
  log.info "**********************************************"

  # make sure the file exists
  if !File.exists?(@db_config_path)
    log.error "The #{@db_config_path} does not exist"
    exit
  end

  db_config = YAML.load_file(@db_config_path)

  begin
    # create connection
    mysql = Mysql2::Client.new(:host => db_config["host"], :port => db_config["port"], :database => db_config["database"],
                                :username => db_config["username"], :password => db_config["password"],
                                :encoding => db_config["encoding"], :reconnect => db_config["reconnect"])

    ####################################################
    # if tables do not exist, create them
    ####################################################
    sql = "CREATE TABLE IF NOT EXISTS `postings` (\
          `id` int(11) NOT NULL AUTO_INCREMENT,\
          `posting_id` varchar(255) not null,\
          `locale` varchar(10) not null,\
          `source` varchar(255) not null,\
          `type` varchar(255) default null,\
          `property_type` varchar(255) default null,\
          `date` date not null,\
          `additional_info` text default null,\
          `daily_rent` varchar(255) default null,\
          `for_rent` varchar(255) default null,\
          `for_sale` varchar(255) default null,\
          `rent_price` numeric(15,2) default null,\
          `rent_price_currency` varchar(10) default null,\
          `rent_price_exchange_rate` numeric(15,5) default null,\
          `rent_price_sq_meter` numeric(15,2) default null,\
          `sale_price` numeric(15,2) default null,\
          `sale_price_currency` varchar(10) default null,\
          `sale_price_exchange_rate` numeric(15,5) default null,\
          `sale_price_sq_meter` numeric(15,2) default null,\
          `space` smallint default null,\
          `space_measurement` varchar(20) default null,\
          `land` smallint default null,\
          `land_measurement` varchar(20) default null,\
          `renovation` varchar(255) default null,\
          `view` varchar(255) default null,\
          `project` varchar(255) default null,\
          `place_condition` varchar(255) default null,\
          `function` varchar(255) default null,\
          `address` varchar(1000) default null,\
          `address_city` varchar(255) default null,\
          `address_area` varchar(255) default null,\
          `address_district` varchar(255) default null,\
          `address_street` varchar(255) default null,\
          `address_number` varchar(255) default null,\
          `phone` varchar(255) default null,\
          `cadastral` varchar(255) default null,\
          `all_floors` smallint default null,\
          `floor` smallint default null,\
          `rooms` smallint default null,\
          `bedrooms` smallint default null,\
          `conference_room` smallint default null,\
          `wc` smallint default null,\
          `bathroom` smallint default null,\
          `shower` smallint default null,\
          `fireplace` smallint default null,\
          `air_conditioner` smallint default null,\
          `balcony` smallint default null,\
          `veranda` smallint default null,\
          `loft` smallint default null,\
          `bodrum` smallint default null,\
          `mansard` smallint default null,\
          `parking` smallint default null,\
          `garage` smallint default null,\
          `dist_from_tbilisi` smallint default null,\
          `dist_from_cent_street` smallint default null,\
          `box` smallint default null,\
          `buildings` smallint default null,\
          `administration_building` smallint default null,\
          `workroom` smallint default null,\
          `stockroom` smallint default null,\
          `coefficient_k1` smallint default null,\
          `coefficient_k2` smallint default null,\
          `created_at` datetime,\
          PRIMARY KEY `Index 1` (`id`),\
          KEY `Index 2` (`posting_id`),\
          KEY `Index 3` (`locale`),\
          KEY `Index 4` (`source`),\
          KEY `Index 5` (`type`),\
          KEY `Index 6` (`property_type`),\
          KEY `Index 7` (`rent_price`),\
          KEY `Index 8` (`sale_price`),\
          KEY `Index 9` (`space`),\
          KEY `Index 10` (`land`),\
          KEY `Index 11` (`address_city`),\
          KEY `Index 12` (`address_area`),\
          KEY `Index 13` (`address_district`),\
          KEY `Index 14` (`address_street`),\
          CONSTRAINT uc_id_locale UNIQUE (posting_id, locale)\
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8"
    mysql.query(sql)


    ####################################################
    # load the data
    ####################################################
    files_processed = 0
    length = @data_path.split('/').length

    @locales.keys.each do |locale_key|
      locale = locale_key.to_s
      # if there are any ids for this locale, procss them
      if @status['ids_to_process']['db'][locale].length > 0
        ids = @status['ids_to_process']['db'][locale].dup
        ids.each do |id|
          parent_id = get_parent_id_folder(id)
          file_path = @data_path + parent_id + "/" + id + "/" + locale + "/" + @json_file
          if File.exists?(file_path)
            # pull in json
            json = JSON.parse(File.read(file_path))
            
            # create sql statement
            sql = create_sql_insert(mysql, json, source, locale)
            if !sql.nil?
              # create record
              mysql.query(sql)
              
              # remove the id from the status list to indicate it was processed
              remove_status_db_id(id, locale)

              files_processed += 1

              if files_processed % 100 == 0
                puts "#{files_processed} json files processed so far"
              end
            end
          end
        end
      end
    end

=begin
    # for each json file in this folder, load into table
    Dir.glob(@data_path + "/**/*.json").sort.each do |json_file|      
      # get the folder id
      folder_id = json_file.split('/')[length+2].to_i

      # get the locale
      locale = json_file.split('/')[length+3]

      ####################################################
      # get data from json file and save to db
      ####################################################
      # pull in json
      json = JSON.parse(File.read(json_file))
      
      # create sql statement
      sql = create_sql_insert(mysql, json, source, locale)
      if !sql.nil?
        log.info sql
        
        # create job
        mysql.query(sql)
        
        # remove the id from the status list to indicate it was processed
        remove_status_db_id(folder_id, locale)

        files_processed += 1

        if files_processed % 100 == 0
          puts "#{files_processed} json files processed so far"
        end
      end
    end
=end

    
    log.info "------------------------------"
    log.info "It took #{Time.now - start} seconds to load #{files_processed} json files into the database"
    log.info "------------------------------"
    
  rescue Mysql2::Error => e
    log.info "+++++++++++++++++++++++++++++++++"
    log.error "Mysql error ##{e.errno}: #{e.error}"
    log.info "+++++++++++++++++++++++++++++++++"
  ensure
    mysql.close if mysql
  end
end
