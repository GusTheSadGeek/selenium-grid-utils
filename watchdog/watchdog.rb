#!/usr/bin/env ruby
require 'sinatra'
require 'json'
require 'open-uri'

externally_visible = '0.0.0.0'
public_folder = 'publid'
set :public_folder, public_folder
set :bind, externally_visible
set :port, 17000

def prt(s)
  puts(s)
end

def help
  if $os == :windows
    cleanup = '<a href="/cleanup">delete temp files - can take quite a while and make pages un responsive</a></br>'
    killie = '<a href="/killie">kill all internet explorer instances</a></br>' +
    killiedriver = '<a href="/killiedriver">kill all internet explorer driver instances</a></br>'
  else
    cleanup = ''
    killie=''
    killiedriver=''
  end
  '</br></br></br></br>' +
      '<a href="/">info</a></br>' +
      '<a href="/status">status</a></br>' +
      '<a href="/reboot">reboot grid node</a></br>' +
      '<a href="/restart">restart selenium node</a></br>' +
      '<a href="/stop">stop selenium node</a></br>' +
      '<a href="/start">start selenium node</a></br>' +
      killie +
      killiedriver +
      '<a href="/killch">kill all chrome instances</a></br>' +
      '<a href="/killchdriver">kill all chrome driver instances</a></br>' +
      '<a href="/killff">kill all firefox instances</a></br>' +
      cleanup +
      '<a href="/updatefromhub">update node from hub - this will stop the node</a></br>' +
      '<a href="/wdrestart">restart watchdog</a></br>' +
      '<a href="/execute">execute command ?cmd="format c"'
end

get '/' do
  $info +
  help()
end

get '/info' do
  $info +
  help()
end

get '/info_json', :provides => :json do
  $info_json.to_json
end


get '/status' do
  "<a id='info'>STATUS: #{get_status()}</a>#{help()}"
end

get '/reboot' do
  stop_selenium()
  reboot()
  help()
end

get '/restart' do
  stop_selenium()
  start_selenium()
  help()
end

get '/wdrestart' do
  exit!
end

get '/stop' do
  stop_selenium()
  help()
end

get '/start' do
  start_selenium()
  help()
end

get '/help' do
  help()
end

get '/killie' do
  killie()
  help()
end

get '/killiedriver' do
  killiedriver()
  help()
end

get '/killch' do
  killch()
  help()
end

get '/killchdriver' do
  killchdriver()
  help()
end


get '/killff' do
  killff()
  help()
end

get '/cleanup' do
  cleanup_temp()
  help()
end


get '/updatefromhub' do
  download_file_from_hub('watchdog.rb')
  stop_selenium()
  download_file_from_hub('selenium-server-standalone.jar')
  if $os == :windows
    download_file_from_hub('IEDriverServer.exe')
    download_file_from_hub('chromedriver.exe')
  else
    download_file_from_hub('chromedriver')
  end
  '<a>DONE</a>'+
  help()
end


def download_file_from_hub(file)
  url = "http://#{$hub_url}/getupdate/#{file}"
  open("#{file}", 'wb') do |file|
    file << open(url).read
  end
end


get '/execute' do
  message = ''
  begin
    if params[:cmd]
      command = params[:cmd]
      run_command(command)
      message = 'command executed'
    else
      message = 'You must specify a command "/execute?cmd=touch /tmp/wibble.txt"'
    end
  rescue => e
    message = e.message
  end
  "<a>#{message}</a>\n" + help()
end

get '/assets/:file' do |file|
  send_file File.join('public', file)
end

post '/upload' do
  message = ''
  begin
    if params[:file]
      filename = params[:file][:filename]
      file = params[:file][:tempfile]
      filepath = File.join('.', filename)
      File.open(filepath, 'wb') do |f|
        f.write file.read
      end
      message = "#{filename} uploaded successfully"
    else
      message = 'You have to choose a file'
    end
  rescue => e
    message = e.message
  end
  "<a>#{message}</a>\n" + help()
end


######################################################################################################################

$debug=false

#require 'socket'           # Get sockets from stdlib
#require 'open3'				     # Allows capturing stderr and stdout
#require 'fileutils'
#require 'json'

#port = 17000   # CHANGE THIS TO SUITE - 17000 is a safe windows port

$controlled_quit = false
$current_info={}

$info={}
$info[:ie]={}
$info[:ff]={}
$info[:ch]={}
$info[:saf]={}

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


def run_command(cmd)
  system(cmd)
end

def killie
  if os == :windows
    system('taskkill /F /IM iexplore.exe')
  end
end

def killiedriver
  if os == :windows
    system('taskkill /F /IM iedriverserver.exe')
  end
end

def killch
  if os == :windows
    system('taskkill /F /IM chrome.exe')
  else
    system('pkill -9 chrome')
  end
end

def killchdriver
  if os == :windows
    system('taskkill /F /IM chromedriver.exe')
  else
    system('pkill -9 googledriver')
  end
end

def killff
  if os == :windows
    system('taskkill /F /IM firefox.exe')
  else
    system('pkill -9 firefox')
  end
end

def reboot
  if $os == :windows
    system('shutdown.exe /r /t 1')
  else
    system('sudo reboot')
  end
end

def shutdown
  if $os == :windows
    system('shutdown.exe /s /t 1')
  else
    system('sudo shutdown now')
  end
end


def restart_selenium
  stop_selenium
  start_selenium
end

def stop_selenium
  if $os == :windows
    system('taskkill /F /IM java.exe')
  else
    #  system('pkill -9 java')
  end
end

def start_selenium
  if $os == :windows
    _ = Process.spawn 'c:/selenium/startnode.cmd'    # Dont care about the returned PID
  else
    _ = Process.spawn '~/startnode.sh'               # Dont care about the returned PID
  end
end

def get_computer_name
  name = 'unavailable'
  if $os == :windows
    begin
      require 'win32/registry'
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName') do |reg|
        name = reg['ComputerName']
      end
    rescue Exception
      prt 'Exception in get_computer_name()'
      prt($!)
      prt($@)
      # Ignore errors
    end
  else
     name = $vm_name
  end
  name
end

def get_ie_version
  version = 'unavailable'
  if $os == :windows
    begin
      require 'win32/registry'
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Microsoft\Internet Explorer') do |reg|
        begin
          version = reg['svcVersion']
        rescue
          version = reg['W2kVersion']    # XP/IE8
        end
      end
    rescue Exception
      prt 'Exception in get_ie_version()'
      prt($!)
      prt($@)
      # Ignore errors
    end
  else
  end
  version.strip()
end

def get_chrome_version
  version = 'unavailable'
  if $os == :windows
    begin
      require 'win32/registry'
      Win32::Registry::HKEY_CURRENT_USER.open('Software\Google\Chrome\BLBeacon') do |reg|
        version = reg['version']
      end
    rescue Exception
      prt 'Exception in get_chrome_version()'
      prt($!)
      prt($@)
      # Ignore errors
    end
  else
    version = `google-chrome --version`
  end
  version.strip()
end

def get_firefox_version
  version = 'unavailable'
  if $os == :windows
    begin
      require 'win32/registry'
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Mozilla\Mozilla Firefox') do |reg|
        version = reg['CurrentVersion']
      end
    rescue Exception
      prt 'Exception in get_firefox_version()'
      prt($!)
      prt($@)
      # Ignore errors
    end
  else
    version = `firefox --version`
  end
  version.strip()
end

def get_os_version
  version = 'unavailable'
  if $os == :windows
    begin
      require 'win32/registry'
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Microsoft\Windows NT\CurrentVersion') do |reg|
        begin name = reg['ProductName'] rescue name='ProductName' end
        begin ver = reg['CurrentVersion'] rescue ver='' end
        begin csdbn = reg['CSDBuildNumber'] rescue csdbn='' end
        begin currentbuild = reg['CurrentBuild'] rescue currentbuild='' end
        version = "#{name} #{ver} #{csdbn} #{currentbuild}"
      end
    rescue Exception
      prt 'Exception in get_os_version()'
      prt($!)
      prt($@)
    end
  else
    version = `uname -a`
  end
  version.strip()
end

def gather_info
  begin
    if File.exist?('./localSettings.rb')
      require_relative './localSettings'
    else
      File.open('./localSettings.rb', 'w') do |file|
        file.puts ('# $host_name="greekname"')
        file.puts ('# $rdp_port=500x')
        file.puts ('# $grid_port=600x')
        file.puts ('# $wd_port=1700x')
      end
    end

    if $os == :windows
      default = 'define me in c:\selenium\localSettings.rb'
    else
      default = 'define me in ~/localSettings.rb'
    end

    $hub_url='lonselhub.we7.local:17000' if $hub_url==nil

    $host_name = default if $host_name==nil
    vm_name = get_computer_name
    $rdp_port = default  if $rdp_port==nil
    $grid_port = default if $grid_port==nil
    $wd_port = default   if $wd_port==nil
    ie_version = get_ie_version
    ch_version = get_chrome_version
    ff_version = get_firefox_version
    os_version = get_os_version

    $password = 'det' if $password==nil
    $user = 'det' if $user==nil

    $remote_cmd = "rdesktop -a 16 -z -xm -P -N #{$host_name}:#{$rdp_port} -u #{$user} -p #{$password} -g 1280x1024 -r sound:remote" if  $remote_cmd==nil

    $max_ie = 1 if $max_ie==nil
    $max_ch = 1 if $max_ch==nil
    $max_ff = 1 if $max_ff==nil
    $max_saf = 0 if $max_saf==nil
    $max_sessions = 2 if $max_sessions==nil

    create_info_string(vm_name,$host_name,$rdp_port,$grid_port,$wd_port,ie_version,ch_version,ff_version,os_version)

  rescue Exception
    prt 'Exception in create_index_html()'
    prt($!)
    prt($@)
  end
end


def create_info_string(vm_name,host_name,rdp_port,grid_port,wd_port,ie_version,ch_version,ff_version,os_version)
  $info = "<html>\n" +
      "<head>\n" +
      "</head>\n" +
      "<body>\n" +
      "<a id='info'>GRID_REF: #{$grid_ref}</a></br>\n" +
      "<a id='info'>VM: #{vm_name}</a></br>\n" +
      "<a id='info'>Host: #{host_name}</a></br>\n" +
      "<a id='info'>RDP: #{host_name}:#{rdp_port}</a></br>\n" +
      "<a id='info'>GRID: #{host_name}:#{grid_port}</a></br>\n" +
      "<a id='info'>WD: #{host_name}:#{wd_port}</a></br>\n" +
      "<a id='info'>OSVER: #{os_version}</a></br>\n" +
      "<a id='info'>IEVER: #{ie_version}</a></br>\n" +
      "<a id='info'>CHVER: #{ch_version}</a></br>\n" +
      "<a id='info'>FFVER: #{ff_version}</a></br>\n" +
      "<a id='info'>MAXIE: #{$max_ie}</a></br>\n" +
      "<a id='info'>MAXCH: #{$max_ch}</a></br>\n" +
      "<a id='info'>MAXFF: #{$max_ff}</a></br>\n" +
      "<a id='info'>MAXSAF: #{$max_saf}</a></br>\n" +
      "<a id='info'>MAXSESSIONS: #{$max_sessions}</p></br>\n" +
      "<a id='info'>RDESKTOP: #{$remote_cmd}</p></br>\n" +
      "</body</br>\n" +
      "</html></br>\n"

  $info_json={
      :grid_ref => $grid_ref,
      :vm_name => vm_name,
      :host_name => host_name,
      :rdp_port => rdp_port,
      :grid_port => grid_port,
      :wd_port => wd_port,
      :os_version => os_version,
      :ie_version => ie_version,
      :ff_version => ff_version,
      :ch_version => ch_version,
      :saf_version => 'unavailable',
      :max_ie => $max_ie,
      :max_ff => $max_ff,
      :max_ch => $max_ch,
      :max_saf => $max_saf,
      :max_sessions => $max_sessions,
      :remote_cmd => $remote_cmd
  }
end


# Selenium likes to fill the temp folder with crap - this attempts to clean it up
def cleanup_temp
  if $os == :windows
    begin
      prt 'Cleaning c:\users\det\AppData\Local\Temp\*'
      FileUtils.rm_rf(Dir.glob('c:/users/det/AppData/Local/Temp/*'))
      prt 'Done cleaning'
    rescue Exception
      prt 'Exception in cleanup_temp()'
      prt($!)
      prt($@)
    end
  end
end


def os
  $os ||= (
  host_os = RbConfig::CONFIG['host_os']
  case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise Error, "unknown os: #{host_os.inspect}"
  end
  )
end


def get_status
  'OK'
end


def main
# What OS ?
  os()

# If windows then clean up temp folder
  if $os == :windows
    cleanup_temp()
  end

# Create index.html
  gather_info()
  restart_selenium()
end


main()


# Windows Cmd
# :loop
# ruby watchdog.rb
# goto loop

