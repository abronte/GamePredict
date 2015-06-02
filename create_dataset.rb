require 'opencv'

def hist(file)
  iplimg = OpenCV::IplImage.decode_image(open(file).read)
  b, g, r = iplimg.split

  dim = 3
  sizes = [8,8,8]
  ranges = [[0, 255],[0, 255],[0, 255]]
  hist = OpenCV::CvHistogram.new(dim, sizes, OpenCV::CV_HIST_ARRAY, ranges, true)
  hist.calc_hist([r, g, b])
end

#greyscale histogram
def ghist(file)
  iplimg = OpenCV::IplImage.decode_image(open(file).read, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  a = iplimg.split[0]

  dim = 1
  sizes = [256]
  ranges = [[0, 255]]
  hist = OpenCV::CvHistogram.new(dim, sizes, OpenCV::CV_HIST_ARRAY, ranges, true)
  hist.calc_hist([a])
end

open("train.txt", "wb") do |file|
  Dir.glob("screens/*/*.jpg").each do |f|
    puts "Processing #{f}"

    h = hist(f)
    vals = []
    cat = f.split("/")[1]

    (0..511).each do |i|
      vals << h[i]
    end

    file.write("\"#{cat}\",#{vals.join(",")}\n")
  end
end
