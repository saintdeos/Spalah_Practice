require 'yaml'
require 'json'
require 'net/http'

def countries(countries, vk_domen, cts_path, unv_path)
  countries.each do |c|
    Dir.mkdir("#{c['title']}")
    Dir.chdir("#{c['title']}")
    cities("#{c['cid']}",vk_domen, cts_path, unv_path)
    Dir.chdir("..")
  end
end

def cities(cid, vk_domen, cts_path, unv_path)
  cities = Net::HTTP.get(vk_domen, cts_path + "&country_id=#{cid}")
  cities = JSON.parse(cities)['response']
  cities.each do |c| 
    Dir.mkdir("#{c['title']}")
    Dir.chdir("#{c['title']}")
    universities("#{c['cid']}",vk_domen, cts_path, unv_path)
    Dir.chdir("..")
  end
end

def universities(cid, vk_domen, cts_path, unv_path)
  universities = Net::HTTP.get(vk_domen, unv_path + "&city_id=#{cid}")
  universities = JSON.parse(universities)['response']
  universities.shift
  File.open('universities.txt', 'a+') do |file| 
    universities.each{ |u| file.puts "#{u['title']}" }
  end
end

VK_CONF = YAML.load(File.read('./config.yml'))['vk']

vk_domen = VK_CONF['domen']
cnt_path = VK_CONF['methods']['countries'] + '?need_all=1&count=2'
cts_path = VK_CONF['methods']['cities'] + '?need_all=0&count=2'
unv_path = VK_CONF['methods']['universities'] + '?count=2'

Dir.mkdir("data")
Dir.chdir("data")

countries = Net::HTTP.get(vk_domen, cnt_path)
countries = JSON.parse(countries)['response']

countries(countries, vk_domen, cts_path, unv_path)