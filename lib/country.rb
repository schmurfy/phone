module Phoner
  class Country < Struct.new(:name, :country_code, :char_2_code, :area_code)
    cattr_accessor :all
    cattr_accessor :quick_list
    cattr_accessor :quick_list_countrycodes

    cattr_accessor :restrict_to_quicklist

    self.all = {}
    self.quick_list = {}
    self.quick_list_countrycodes = [] # example: %w(33 49)
    self.restrict_to_quicklist = false

    def self.load
      return all if all.present?

      data_file = File.join(File.dirname(__FILE__), '..', 'data', 'phone_countries.yml')

      YAML.load(File.read(data_file)).each do |key, c|
        all[key] = Country.new(c[:name], c[:country_code], c[:char_2_code], c[:area_code])
        if quick_list_countrycodes.include?(key)
          quick_list[key] = all[key]
        end
      end


      all
    end

    def to_s
      name
    end

    # detect country for this number
    def self.find_by_phone(str, source = quick_list)
      source.each do |country_code, country|
        if str =~ country.country_code_regexp
          return country
        end
      end

      # not found
      if !restrict_to_quicklist && (source != all)
        puts "Not in quicklist: #{str}"
        find_by_phone(str, all)
      end
    end

    def self.find_by_country_code(code)
      @@all[code]    
    end

    def country_code_regexp
      @regexp ||= Regexp.new("^[+]#{country_code}")    
    end

    def formats
      @formats ||= {
        # 047451588, 013668734
        :short => Regexp.new('^0?(' + (area_code || Phone::DEFAULT_AREA_CODE) + ')' + Phone::NUMBER),
        # 451588
        :really_short => Regexp.new('^' + Phone::NUMBER)
      }
    end

  end
  
end