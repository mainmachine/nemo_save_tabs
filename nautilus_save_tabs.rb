#!/usr/bin/env ruby

require 'socket'

# nautilus module
module Nautilus
  ## (1..30).select {|n| 60 % n == 0}
  #
  # array.each_slice
  # save tabs
  class SaveTabs
    SLEEP_TIME = 0.05
    MAX_TAB = 5
    KEY_DELAY = 1000

    SHORTCUT_GETURIS = 'control+g'.freeze
    SAVE_TABS_PATH = ENV['HOME'] + '.config/nautilus/save_tabs'
    SOCKET_PATH = '/tmp/nautilus_' + ENV['USER'] + '.socket'

    @uriss = ''

    def key(keys)
      p = 'xdotool key ' + keys
      #  p = "xdotool --delay" + KEY_DELAY + keys + "control+l control+c"
      system(p)
      sleep(SLEEP_TIME)
    end

    def read_socket
      Thread.start do
        Socket.unix_server_loop(SOCKET_PATH) do |sock, _addr|
          begin
            @uris = sock.read
            break
          rescue Errno::EPIPE => e
            p e
            break
          end
        end
      end
    end

    def uris
      thread = read_socket
      key(SHORTCUT_GETURIS)
      thread.join
      p @uris
      @uris
    end

    def first_tab
      key('alt+1')
      uris
    end

    def next_tab
      key('control+Page_Down')
      uris
    end

    def prev_tab
      key('control+Page_Up')
      uris
    end

    def nth_tab(n)
      n = [9, [0, n].max].min
      key("alt+#{n}")
      uris
    end

    def initialize
      uris_forward = [first_tab]
      MAX_TAB.times do
        uris_forward << next_tab
      end

      system("zenity --list \
                    --title='Session saved' \
                    --width=800 --height=600 \
                    --column='Name' --column='Value' \
                    'uris' #{uris_forward}")
    end
  end
end

Nautilus::SaveTabs.new
