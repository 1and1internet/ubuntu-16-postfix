require 'serverspec'
require 'docker'
require_relative '../../drone-tests/shared/jemonkeypatch.rb'

#Include Tests
base_spec_dir = Pathname.new(File.join(File.dirname(__FILE__)))
Dir[base_spec_dir.join('../../drone-tests/shared/**/*.rb')].sort.each { |f| require_relative f }

if not ENV['IMAGE'] then
  puts "You must provide an IMAGE env variable"
end

image_path = File.dirname(__FILE__).split("/")[-2].gsub(/^docker-/, "")
if ENV['IMAGE'] != image_path then
  puts "\e[31mWARNING: IMAGE variable #{ENV['IMAGE']} does not match spec test path #{image_path}\e[0m"
end

CONTAINER_START_DELAY=2

RSpec.configure do |c|
  @image = Docker::Image.get(ENV['IMAGE'])
  set :backend, :docker
#  set :docker_debug, true
  set :docker_image, @image.id
  set :docker_container_start_timeout, 5

  describe "tests" do
    include_examples 'postfix'
  end
end

