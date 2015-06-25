class Config < Settingslogic
  source "#{Rails.root}/config/settings/config.yml"
  namespace Rails.env
end
