require 'sinatra'
require_relative './gridMonitor'

externally_visible = '0.0.0.0'
public_folder = './public'
set :public_folder, public_folder
set :bind, externally_visible
set :port, 17000


#gherkin_root_dir = "/home/gus/git/radio-site/cucumberTest/watir/features"
#dic = GherkinDictionary.new(gherkin_root_dir)

filepath = File.join('public', 'index.html')
$index = File.read( filepath )


get '/' do
  $index
end

# get '/all', :provides => 'text/plain' do
# #  dic.to_s
# end
#
# get '/autocomplete', :provides => :json do
# #  dic.find_terms(params[:query] || "").to_json
# end


get '/auto_update', :provides => :json do
  # nodes =[]
  # nodes.push({:name => 'Aiakos_Linux', :status=>'OK', :lastseen=>"#{Time.now.to_s}"})
  # nodes.push({:name => 'X7IE10', :status=>'NOK', :lastseen=>"#{Time.now.to_s}"})
  # nodes.to_json()
  GridMonitor.get_nodes()
end


get '/assets/:file' do |file|
  send_file File.join('public', file)
end

get '/getupdate/:file' do |file|
  send_file File.join('updatefiles', file)
end

get '/setinfo' do
  if params[:info]
    info = params[:info]
    sender = params[:sender]
    test = params[:test]
    br = params[:br]
    ref = params[:ref]
    GridMonitor.setinfo(ref, sender, test, br, info)
  end
  'OK'
end


GridMonitor.monitor()