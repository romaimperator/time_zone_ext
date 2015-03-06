require 'tzinfo'
require "active_support/dependencies/autoload" # Required for Numbers
require "active_support/deprecation" # Required by core_ext/module/deprecation
require "active_support/core_ext"
require "time_zone_ext/version"

module TimeZoneExt
  def strptime(date, format)
    if format =~ /%z/i
      DateTime.strptime(date, format).in_time_zone
    else
      time_in_zone = DateTime.strptime("#{date} zone#{Time.zone.formatted_offset}", "#{format} zone%z").in_time_zone
      # Correct the time because zone will be wrong if given date is in daylight
      # savings but Time.zone.now is not in daylight savings
      time_in_zone - (time_in_zone.utc_offset - Time.zone.utc_offset).seconds
    end
  end
end

ActiveSupport::TimeZone.send :include, TimeZoneExt
