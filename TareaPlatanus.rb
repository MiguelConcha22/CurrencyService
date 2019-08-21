require 'date'
require 'nokogiri'
require 'open-uri'
require 'net/http'

class CurrencyService
  def initialize()
    historical(ARGV[0], ARGV[1])
  end
  def historical(from_date, to_date)
    currency = Hash.new
    (Date.parse(from_date)..Date.parse(to_date)).each_with_index do |date, i|
      values = getCurrency(date)
      if i == 0
        currency[date.to_s] = {
          :usd => {
            :today => values[1],
            :diff => nil
          },
          :uf => {
            :today => values[0],
            :diff => nil
          }
        }
      else
        currency[date.to_s] = {
          :usd => {
            :today => values[1],
            :diff => (values[1] - currency[(date - 1).to_s][:usd][:today]).round(2)
          },
          :uf => {
            :today => values[0],
            :diff => (values[0] - currency[(date - 1).to_s][:uf][:today]).round(2)
          }
        }
      end
    end
    puts currency
  end
  def getCurrency(date)
    values = []
    #html = open("https://si3.bcentral.cl/bdemovil/BDE/IndicadoresDiarios?parentMenuName=Indicadores%20diarios&fecha=#{date.strftime('%d-%m-%Y')}").read
    #html = open("https://news.ycombinator.com").read
    uri = URI("https://si3.bcentral.cl/bdemovil/BDE/IndicadoresDiarios?parentMenuName=Indicadores%20diarios&fecha=#{date.strftime('%d-%m-%Y')}")
    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri

      response = http.request request # Net::HTTPResponse object
      doc = Nokogiri::HTML(response.body)
      i = 0
      doc.search('td.col-xs-2').map do |element|
      #doc.search('.score').map do |element|
        #puts element.inner_text
        if(i < 2)
          values << element.inner_text.gsub(/\./mi, '').gsub(',', '.').to_f
          #values << 27000 * i + 600
          i += 1
        end
      end
    end
    return values
  end
end
newService = CurrencyService.new()
