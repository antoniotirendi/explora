require 'business_time'

require_rel '**/*.rb'

BusinessTime::Config.load(File.expand_path(File.join(__dir__, '..','config', 'business_time.yml')))