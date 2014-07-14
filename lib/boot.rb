require 'business_time'

require_rel '**/*.rb'

BusinessTime::Config.holidays << Date.parse('02/06/2014')