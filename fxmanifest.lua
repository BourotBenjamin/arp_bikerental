fx_version 'adamant'
game 'gta5'

name 'ARP Bike-Rental'
description 'Rent a bike to make your way faster to you location!'
author 'hoaaiww'
version 'v1.2'

server_scripts {
  'config.lua',
  'server/server.lua'
}

client_scripts {
  '@menuv/menuv.lua',
  'config.lua',
  'client/client.lua'
}