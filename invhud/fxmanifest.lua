fx_version 'bodacious'

game 'gta5'

ui_page "html/ui.html"

client_scripts {
  "@es_extended/locale.lua",
  "locales/*.lua",
  "config.lua",
  "client.lua"
}

server_scripts {
  "@mysql-async/lib/MySQL.lua",
  "@es_extended/locale.lua",
  "locales/*.lua",
  "config.lua",
  "server.lua"
}

files {
  "html/ui.html",
  "html/**/*.css",
  "html/**/*.js",
  -- JS LOCALES
  "html/**/*.js",
  -- IMAGES
  "html/**/*.png"
}

dependency 'es_extended'