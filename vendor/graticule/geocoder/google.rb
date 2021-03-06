
module Graticule #:nodoc:
  module Geocoder #:nodoc:
  
    # First you need a Google Maps API key.  You can register for one here:
    # http://www.google.com/apis/maps/signup.html
    # 
    # Then you create a GoogleGeocode object and start locating addresses:
    # 
    #   require 'rubygems'
    #   require 'graticule'
    # 
    #   gg = Graticule.service(:google).new(:key => MAPS_API_KEY)
    #   location = gg.locate '1600 Amphitheater Pkwy, Mountain View, CA'
    #   p location.coordinates
    # 
    class Google < Rest
      # http://www.google.com/apis/maps/documentation/#Geocoding_HTTP_Request
    
      # http://www.google.com/apis/maps/documentation/reference.html#GGeoAddressAccuracy
      PRECISION = {
        0 => :unknown,      # Unknown location. (Since 2.59)
        1 => :country,      # Country level accuracy. (Since 2.59)
        2 => :state,        # Region (state, province, prefecture, etc.) level accuracy. (Since 2.59)
        3 => :state,        # Sub-region (county, municipality, etc.) level accuracy. (Since 2.59)
        4 => :city,         # Town (city, village) level accuracy. (Since 2.59)
        5 => :zip,          # Post code (zip code) level accuracy. (Since 2.59)
        6 => :street,       # Street level accuracy. (Since 2.59)
        7 => :street,       # Intersection level accuracy. (Since 2.59)
        8 => :address       # Address level accuracy. (Since 2.59)
      }

      # Creates a new GoogleGeocode that will use Google Maps API key +key+.  You
      # can sign up for an API key here:
      #
      # http://www.google.com/apis/maps/signup.html
      def initialize(key)
        @key = key
        @url = URI.parse 'http://maps.google.com/maps/geo'
      end

      # Locates +address+ returning a Location
      def locate(address)
        get :q => address.is_a?(String) ? address : location_from_params(address).to_s
      end

      # Extracts a Location from +xml+.
      def parse_response(xml) #:nodoc:
        address = REXML::XPath.first(xml, '//xal:AddressDetails', 'xal' => "urn:oasis:names:tc:ciq:xsdschema:xAL:2.0")

        longitude, latitude, = xml.elements['/kml/Response/Placemark/Point/coordinates'].text.split(',').map { |v| v.to_f }
      
        Location.new \
          :street => value(address.elements['Country/AdministrativeArea/SubAdministrativeArea/Locality/Thoroughfare/ThoroughfareName/text()']),
          :locality => value(address.elements['Country/AdministrativeArea/SubAdministrativeArea/Locality/LocalityName/text()']),
          :region => value(address.elements['Country/AdministrativeArea/AdministrativeAreaName/text()']),
          :postal_code => value(address.elements['Country/AdministrativeArea/SubAdministrativeArea/Locality/PostalCode/PostalCodeNumber/text()']),
          :country => value(address.elements['Country/CountryNameCode/text()']),
          :latitude => latitude,
          :longitude => longitude,
          :precision => PRECISION[address.attribute('Accuracy').value.to_i] || :unknown
      end

      # Extracts and raises an error from +xml+, if any.
      def check_error(xml) #:nodoc:
        status = xml.elements['/kml/Response/Status/code'].text.to_i
        case status
        when 200 then # ignore, ok
        when 500 then
          raise Error, 'server error'
        when 601 then
          raise AddressError, 'missing address'
        when 602 then
          raise AddressError, 'unknown address'
        when 603 then
          raise AddressError, 'unavailable address'
        when 610 then
          raise CredentialsError, 'invalid key'
        when 620 then
          raise CredentialsError, 'too many queries'
        else
          raise Error, "unknown error #{status}"
        end
      end

      # Creates a URL from the Hash +params+.  Automatically adds the key and
      # sets the output type to 'xml'.
      def make_url(params) #:nodoc:
        params[:key] = @key
        params[:output] = 'xml'

        super params
      end
    
      private
    
        def value(element)
          element.value if element
        end
    
        def text(element)
          element.text if element
        end
    end
  end
end