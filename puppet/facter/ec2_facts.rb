#!/usr/bin/ruby

require 'net/http'
require 'uri'
ec2_base_url = "http://169.254.169.254/latest/meta-data/"

def fetch_list(myurl)
  list = []
  begin
    status = Timeout::timeout(2) do
      url = URI.parse(myurl)
      list = []
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.get(url.path)
      }
      res.body.split.each do |x|
        if x =~ /.*\/$/
          list.concat(fetch_list(myurl + x))
        else
          list << "#{myurl}#{x}"
        end
      end
    end
  rescue
    list = []
  rescue Timeout::Error
    list = []
  end
  list
end

def fetch_info(myurl)
  url = URI.parse(myurl)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.get(url.path)
  }
  if res.code == "200"
    if res.body =~ /\n/
      result = res.body.split("\n").join(",")
    else
      result = res.body
    end
    result
  end
end

fact_list = fetch_list(ec2_base_url)
fact_list.each do |x|
  y = fetch_info(x)
  unless y == nil
    Facter.add("ec2_#{x.sub(ec2_base_url, "").sub("/", "_").sub("-", "_")}") do
      confine :virtual => "xenu"
      setcode do
        y
      end
    end
  end
end
