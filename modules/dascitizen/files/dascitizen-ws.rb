#!/usr/bin/env ruby
#
# Based on:
# http://stackoverflow.com/questions/3696558
#
require 'sinatra'
require 'json'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'yaml'

# Cheap cert:
# apt-get install ssl-cert
# sudo cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/dascitizen/server.key
# sudo cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/dascitizen/server.crt

class TincMasterWS < Sinatra::Base
  
  conf = YAML.load_file '/etc/dascitizen/settings.yaml'
  set :username, conf['username']
  set :password, conf['password']

  use Rack::Auth::Basic do |u, p|
    u == settings.username && p == settings.password
  end

  get '/nodes/keys' do
    hosts = []
    Dir['/etc/dascitizen/hosts/*'].each do |f|
      begin
        host = {}
        host[:name] = File.basename(f) 
        host[:body] = File.read(f)
        hosts << host
      rescue
        $stderr.puts "Error reading file #{f}"
      end
    end
    hosts.to_json
  end

end

CERT_PATH = '/etc/dascitizen'
cert = File.read(File.join(CERT_PATH, "server.crt"))
key  = File.read(File.join(CERT_PATH, "server.key"))

webrick_options = {
  :Port               => 9669,
  :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  :DocumentRoot       => "/dev/null",
  :SSLEnable          => true,
  :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
  :SSLCertificate     => OpenSSL::X509::Certificate.new(cert),
  :SSLPrivateKey      => OpenSSL::PKey::RSA.new(key),
  :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ],
  :app                => TincMasterWS
}

trap(:INT) do
  Rack::Handler::WEBrick.shutdown
end

set :run, false
Rack::Handler::WEBrick.run TincMasterWS, webrick_options
