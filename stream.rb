require 'rest-client'
require 'ruby-ffmpeg'
require 'stringio'
require 'opencv'
require 'json'
require 'liblinear'

$model = Liblinear::Model.new("games.model")
games = {1 => "csgo", 2 => "dota2", 3 => "hearthstone", 4 => "minecraft", 5 => "starcraft"}

def histogram(data)
  iplimg = OpenCV::IplImage.decode_image(data)
  b, g, r = iplimg.split

  dim = 3
  sizes = [8,8,8]
  ranges = [[0, 255],[0, 255],[0, 255]]
  hist = OpenCV::CvHistogram.new(dim, sizes, OpenCV::CV_HIST_ARRAY, ranges, true)
  hist.calc_hist([r, g, b])
end

url = ARGV[0]
channel = url.split("/")[-1]

token = JSON.parse(RestClient.get("https://api.twitch.tv/api/channels/#{channel}/access_token?as3=t"))

playlist = RestClient.get("http://usher.justin.tv/api/channel/hls/#{channel}.m3u8?sig=#{token["sig"]}&token=#{token["token"]}")

url = playlist.split("\n")[4]
base = url.split("py-index")[0]
prediction = {}
video = ""

parts = RestClient.get(url)
parts.split("\n").select{|x| x[0] != "#"}.each do |p|
  u = "#{base}#{p}"

  puts "Downloading #{u}"
  resp = RestClient.get(u)
  video = video + resp.body
end

cnt = 0

FFMPEG::Reader.open(StringIO.new(video)) do |reader|
  stream = reader.streams.select { |s| s.type == :video }.first

  while frame = stream.decode do
    if cnt % 60 == 0
      puts "Predicting frame @ #{frame.timestamp}"

      h = histogram(frame.to_bmp)
      vals = []

      (0..511).each do |i|
        vals << h[i]
      end

      res = $model.predict(vals)
      if prediction[res]
        prediction[res] += 1
      else
        prediction[res] = 1
      end
    end

    cnt += 1
  end
end

sorted = prediction.sort_by {|_key, value| value}.reverse

puts "\nDetected: #{games[sorted.first[0].to_i]}"

puts "\nPrediction results:"

sorted.each do |k, v|
  puts "#{games[k.to_i]}: #{v}"
end

