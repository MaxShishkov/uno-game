require 'pusher'

Pusher.app_id = '154361'
Pusher.key = '01eda5cd7a1c80c5aa86'
Pusher.secret = 'e8b38d649786c8d0ec10'
Pusher.url = "https://01eda5cd7a1c80c5aa86:e8b38d649786c8d0ec10@api.pusherapp.com/apps/154361"
Pusher.logger = Rails.logger

#Pusher.trigger('test_channel', 'my_event', {
  #message: 'Kenny Push Message'
#})
