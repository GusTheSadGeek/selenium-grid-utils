# =begin
# #!/usr/bin/env ruby
#
# $debug=false
#
# require 'socket'           # Get sockets from stdlib
# require 'open3'				     # Allows capturing stderr and stdout
# require 'fileutils'
# require 'json'
#
# port = 17000   # CHANGE THIS TO SUITE - 17000 is a safe windows port
#
# $controlled_quit = false
# $current_info={}
#
# $info={}
# $info[:ie]={}
# $info[:ff]={}
# $info[:ch]={}
# $info[:saf]={}
#
# def prt(s)
#   if $os == :windows
#     puts s
#   else
#
#   end
# end
#
# def rx_message(sock)
#   con = sock.accept
#   data = con.readline
#   con.close
#   return data
# end
#
# def tx_string(sock, text)
#   begin
#     prt text
#     sock.puts text
#   rescue
#     prt "ERROR"
#   end
# end
#
# def listen(port)
#   prt '==========================================================================='
#   prt "Listening on port #{String(port)}"
#   sock = nil
#   begin
#     TCPServer.open('0.0.0.0', port) do |sock|
#       first_word=''
#       while first_word != 'QUIT' do
#         begin
#           $retstring = 'OK'
#           prt '----------------------------------------------------------------------'
#           con = sock.accept
#           rx_msg = con.readline
#           prt '----------------------------------------------------------------------'
#           prt "RX: #{rx_msg}"
#           rx = rx_msg.strip
#           if rx.length > 0
#             first_word = rx.split(' ')[0]
#             case first_word
#               when 'SETINFO'
#                 set_info(rx.split(' ')[1..-1])
#               when 'GETINFO'
#                 get_info(rx.split(' ')[1], con)
#               when 'KILLIE'
#                 killie()
#               when 'KILLIEDRIVER'
#                 killiedriver()
#               when 'KILLCH'
#                 killch()
#               when 'KILLCHDRIVER'
#                 killchdriver()
#               when 'KILLFF'
#                 killff()
#               when 'CLEANUP'
#                 cleanup_temp()
#               when 'REBOOT'
#                 stop_selenium
#                 reboot
#               when 'SHUTDOWN'
#                 stop_selenium
#                 shutdown
#               when 'STOP_SELENIUM'
#                 stop_selenium
#               when 'START_SELENIUM'
#                 start_selenium
#               when 'RESTART_SELENIUM'
#                 restart_selenium
#               when 'EX'
#                 run_command(rx[3..-1])
#               when 'FILE:'
#                 # Close the current connection as the file transfer will open a new one
#                 con.close
#                 con = nil
#                 download_file(sock, rx[5..-1])
#               else
#                 prt 'Unknown command - ignoring'
#                 $retstring = 'KO'
#             end
#             if con
#               con.puts $retstring
#               con.close
#             end
#           end
#         rescue Exception
#           prt 'Exception processing command'
#           prt($!)
#           prt($@)
#         end
#       end
#     end
#   rescue Exception
#     prt 'Exception opening socket'
#     prt($!)
#     prt($@)
#   end
#   prt 'Quitting'
#   if sock
#     sock.close()
#   end
#   $controlled_quit = true
# end
#
# require 'digest/md5'
# def download_file(sock, filename)
#   parts = filename.split(':')
#   file = parts[0].strip
#   con = sock.accept
#   data = con.read
#   md5 = Digest::MD5.hexdigest(data)
#   if parts.length > 1
#     expected_md5 = filename.split(':')[1].strip
#   else
#     expected_md5 = md5
#   end
#
#   if md5 == expected_md5
#     prt "Rx data len #{data.length}"
#     prt "Saving file to #{file}"
#     File.binwrite(file, data)
#   else
#     prt "MD5 not matching for file #{file}"
#   end
# end
#
# def set_info(words)
#   begin
#     browser = words[0]
#     if browser.include? 'IE'
#       b = :ie
#     elsif browser.include? 'FF'
#       b = :ff
#     elsif browser.include? 'CH'
#       b = :ch
#     elsif browser.include? 'SAF'
#       b = :saf
#     end
#
#     if words[1].length >= 20
#       if $info[b][:max] > 1
#         unique = words[1]
#       else
#         unique = 0
#       end
#       the_rest = words[2..-1].join(' ')
#     else
#       unique = 0
#       the_rest = words[1..-1].join(' ')
#     end
#
#     if words.count > 2
#       $info[b][unique] = "#{the_rest}"
#     else
#       if unique == 0
#         $info[b][0] = ''
#       else
#         $info[b].delete(unique)
#       end
#     end
#   rescue
#     prt ("Failed to setinfo for #{browser} #{the_rest}")
#   end
# end
#
# def get_info(browser, sock)
#   tx_string(sock,$info.to_json)
# end
#
#
# def run_command(cmd)
#   system(cmd)
# end
#
# def killie
#   system('taskkill /F /IM iexplore.exe')
# end
#
# def killiedriver
#   system('taskkill /F /IM iedriverserver.exe')
# end
#
# def killch
#   system('taskkill /F /IM chrome.exe')
# end
#
# def killchdriver
#   system('taskkill /F /IM chromedriver.exe')
# end
#
# def killff
#   system('taskkill /F /IM firefox.exe')
# end
#
# def reboot
#   if $os == :windows
#     system('shutdown.exe /r /t 1')
#   else
#     system('sudo reboot')
#   end
# end
#
# def shutdown
#   if $os == :windows
#     system('shutdown.exe /s /t 1')
#   else
#     system('sudo shutdown now')
#   end
# end
#
#
# def restart_selenium
#   stop_selenium
#   start_selenium
# end
#
# def stop_selenium
#   if $os == :windows
#     system('taskkill /F /IM java.exe')
#   else
#     system('pkill -9 java')
#   end
# end
#
# def start_selenium
#   if $os == :windows
#     _ = Process.spawn 'c:/selenium/startnode.cmd'    # Dont care about the returned PID
#   else
#     _ = Process.spawn '~/startnode.sh'               # Dont care about the returned PID
#   end
# end
#
# def get_computer_name
#   name = 'unavailable'
#   if $os == :windows
#     begin
#       require 'win32/registry'
#       Win32::Registry::HKEY_LOCAL_MACHINE.open('SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName') do |reg|
#         name = reg['ComputerName']
#       end
#     rescue Exception
#       prt 'Exception in get_computer_name()'
#       prt($!)
#       prt($@)
#       # Ignore errors
#     end
#   else
#
#   end
#   name
# end
#
# def get_ie_version
#   version = 'unavailable'
#   if $os == :windows
#     begin
#       require 'win32/registry'
#       Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Microsoft\Internet Explorer') do |reg|
#         begin
#           version = reg['svcVersion']
#         rescue
#           version = reg['W2kVersion']    # XP/IE8
#         end
#       end
#     rescue Exception
#       prt 'Exception in get_ie_version()'
#       prt($!)
#       prt($@)
#       # Ignore errors
#     end
#   else
#   end
#   version
# end
#
# def get_chrome_version
#   version = 'unavailable'
#   if $os == :windows
#     begin
#       require 'win32/registry'
#       Win32::Registry::HKEY_CURRENT_USER.open('Software\Google\Chrome\BLBeacon') do |reg|
#         version = reg['version']
#       end
#     rescue Exception
#       prt 'Exception in get_chrome_version()'
#       prt($!)
#       prt($@)
#       # Ignore errors
#     end
#   else
#     version = `google-chrome --version`
#   end
#   version
# end
#
# def get_firefox_version
#   version = 'unavailable'
#   if $os == :windows
#     begin
#       require 'win32/registry'
#       Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Mozilla\Mozilla Firefox') do |reg|
#         version = reg['CurrentVersion']
#       end
#     rescue Exception
#       prt 'Exception in get_firefox_version()'
#       prt($!)
#       prt($@)
#       # Ignore errors
#     end
#   else
#     version = `firefox --version`
#   end
#   version
# end
#
# def get_os_version
#   version = 'unavailable'
#   if $os == :windows
#     begin
#       require 'win32/registry'
#       Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Microsoft\Windows NT\CurrentVersion') do |reg|
#         begin name = reg['ProductName'] rescue name='ProductName' end
#         begin ver = reg['CurrentVersion'] rescue ver='' end
#         begin csdbn = reg['CSDBuildNumber'] rescue csdbn='' end
#         begin currentbuild = reg['CurrentBuild'] rescue currentbuild='' end
#         version = "#{name} #{ver} #{csdbn} #{currentbuild}"
#       end
#     rescue Exception
#       prt 'Exception in get_os_version()'
#       prt($!)
#       prt($@)
#     end
#   else
#     version = `uname -a`
#   end
#   version
# end
#
# def create_index_html
#   begin
#     if File.exist?('./localSettings.rb')
#       require_relative './localSettings'
#     else
#       File.open('./localSettings.rb', 'w') do |file|
#         file.puts ('# $host_name="greekname"')
#         file.puts ('# $rdp_port=500x')
#         file.puts ('# $grid_port=600x')
#         file.puts ('# $wd_port=1700x')
#       end
#     end
#
#     if $os == :windows
#       default = 'define me in c:\selenium\localSettings.rb'
#     else
#       default = 'define me in ~/localSettings.rb'
#     end
#
#
#     $host_name = default if $host_name==nil
#     vm_name = get_computer_name
#     $rdp_port = default  if $rdp_port==nil
#     $grid_port = default if $grid_port==nil
#     $wd_port = default   if $wd_port==nil
#     ie_version = get_ie_version
#     ch_version = get_chrome_version
#     ff_version = get_firefox_version
#     os_version = get_os_version
#     write_index_html(vm_name,$host_name,$rdp_port,$grid_port,$wd_port,ie_version,ch_version,ff_version,os_version)
#
#     $remote_cmd = "rdesktop -a 16 -z -xm -P -N #{$host_name}:#{$rdp_port} -u det -p det -g 1280x1024 -r sound:remote" if  $remote_cmd==nil
#     $max_ie = 1 if $max_ie==nil
#     $max_ch = 1 if $max_ch==nil
#     $max_ff = 1 if $max_ff==nil
#     $max_saf = 0 if $max_saf==nil
#     $max_sessions = 2 if $max_sessions==nil
#
#     $info[:host] = $host_name
#     $info[:vm_name] = vm_name
#     $info[:remote_desktop]  = $remote_cmd
#     $info[:ie_version] = ie_version
#     $info[:ch_version] = ch_version
#     $info[:ff_version] = ff_version
#     $info[:os_version] = os_version
#     $info[:grid_port] = $grid_port
#
#     init_browser($info[:ie], $max_ie)
#     init_browser($info[:ch], $max_ch)
#     init_browser($info[:ff], $max_ff)
#     init_browser($info[:saf], $max_saf)
#
#     $info[:sessions]=$max_sessions
#     $info[:status]='OK'
#
#   rescue Exception
#     prt 'Exception in create_index_html()'
#     prt($!)
#     prt($@)
#   end
# end
#
#
# def init_browser(b,m)
#   b[:max]=m
#   if m==1
#     (1..m).each do |n|
#       b[n-1]=''
#     end
#   end
# end
#
# def write_index_html(vm_name,host_name,rdp_port,grid_port,wd_port,ie_version,ch_version,ff_version,os_version)
#   if $os == :windows
#     filename = 'c:/www/root/index.html'
#   else
#     filename = 'index.html'
#   end
#
#   File.open(filename, 'w') do |file|
#     file.puts('<html>')
#     file.puts('<head>')
#     file.puts('<title>Selenium Webdriver</title>')
#     file.puts('</head>')
#     file.puts('<body>')
#     file.puts("<p id='info'>VM: #{vm_name}")
#     file.puts("<p id='info'>Host: #{host_name}")
#     file.puts("<p id='info'>RDP: #{host_name}:#{rdp_port}")
#     file.puts("<p id='info'>GRID: #{host_name}:#{grid_port}")
#     file.puts("<p id='info'>WD: #{host_name}:#{wd_port}")
#     file.puts("<p id='info'>IEVER: #{ie_version}")
#     file.puts("<p id='info'>CHVER: #{ch_version}")
#     file.puts("<p id='info'>FFVER: #{ff_version}")
#     file.puts("<p id='info'>OSVER: #{os_version}")
#     file.puts('</body')
#     file.puts('</html>')
#   end
# end
#
# # Selenium likes to fill the temp folder with crap - this attempts to clean it up
# def cleanup_temp
#   if $os == :windows
#     begin
#       prt 'Cleaning c:\users\det\AppData\Local\Temp\*'
#       FileUtils.rm_rf(Dir.glob('c:/users/det/AppData/Local/Temp/*'))
#       prt 'Done cleaning'
#     rescue Exception
#       prt 'Exception in cleanup_temp()'
#       prt($!)
#       prt($@)
#     end
#   end
# end
#
#
# def os
#   $os ||= (
#   host_os = RbConfig::CONFIG['host_os']
#   case host_os
#     when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
#       :windows
#     when /darwin|mac os/
#       :macosx
#     when /linux/
#       :linux
#     when /solaris|bsd/
#       :unix
#     else
#       raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
#   end
#   )
# end
#
#
# #################################################################################
# # Start of code...
# #
# # trap("SIGINT") { throw :ctrl_c }
# # catch :ctrl_c do
# #
# #   os()
# #
# #   if $os == :windows
# #     cleanup_temp()
# #   end
# #
# #   restart_selenium()
# #   create_index_html()
# #   listen(port)
# #
# #   if !$controlled_quit
# #     # Should never get here - if we do then something has gone wrong - so reboot
# #     stop_selenium
# #     reboot
# #   end
# #
# # end
# =end
