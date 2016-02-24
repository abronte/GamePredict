require 'liblinear'
require 'opencv'

games = {1 => "csgo", 2 => "dota2", 3 => "hearthstone", 4 => "minecraft", 5 => "starcraft"}

def hist(file)
  iplimg = OpenCV::IplImage.decode_image(open(file).read)
  b, g, r = iplimg.split

  dim = 3
  sizes = [8,8,8]
  ranges = [[0, 255],[0, 255],[0, 255]]
  hist = OpenCV::CvHistogram.new(dim, sizes, OpenCV::CV_HIST_ARRAY, ranges, true)
  hist.calc_hist([r, g, b])
end

model = Liblinear::Model.new("games.model")

h = hist(ARGV[0])
vals = []

(0..511).each do |i|
  vals << h[i]
end

puts "Guessing what game for #{ARGV[0]}"
puts "Prediction: #{games[model.predict(vals).to_i]}"

model.save("games.model")
