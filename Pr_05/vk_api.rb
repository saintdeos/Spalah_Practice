require 'yaml'
require 'json'
require 'httparty'

class VkApi
  include HTTParty
  VK_CONF = YAML.load(File.read('./config.yml'))['vk']

  base_uri VK_CONF['domen']

  def grub
    dir_check(VK_CONF['base_dir'])
    countries
    dir_countries
  end

  def countries
    @countries ||= JSON.parse countries_response.body
    @countries = @countries['response']
  end

  def cities(cid)
    @cities = JSON.parse cities_response(cid).body
    @cities = @cities['response']
  end

  def universities(cid)
    @universities = JSON.parse universities_response(cid).body
    @universities = @universities['response']
    @universities.shift
  end

  private

  def countries_response
    @countries_response ||= self.class.get(countries_path, query: { need_all: 1, count: 2 })
  end

  def countries_path
    @countries_path ||= VK_CONF['methods']['countries']
  end

  def cities_response(cid)
    @cities_response = self.class.get(cities_path, query: { country_id: cid, need_all: 0, count: 2 })
  end

  def cities_path
    @cities_path = VK_CONF['methods']['cities']
  end

  def universities_response(cid)
    @universities_response = self.class.get(universities_path, query: { city_id: cid, count: 2 })
  end

  def universities_path
    @universities_path = VK_CONF['methods']['universities']
  end

  def dir_countries
    Dir.chdir(VK_CONF['base_dir']) do |d|
      @countries.each { |c| dir_cities(c) }
    end
  end

  def dir_cities(country)
    dir_check(country['title'])
    cities(country['cid'])
    Dir.chdir(country['title']) do |d|
      @cities.each { |c| dir_universities(c) }
    end
  end

  def dir_universities(city)
    dir_check(city['title'])
    universities(city['cid'])
    Dir.chdir(city['title']) { file_new }
  end

  def file_new
    File.open('universities.txt', 'a+') do |file| 
      @universities.each{ |u| file.puts "#{u['title']}" }
    end
  end

  def dir_check(name)
    Dir.mkdir(name) unless Dir.exist?(name)
  end
end