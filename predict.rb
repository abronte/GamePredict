require 'opencv'
require 'json'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

PROJECT = 'YOUR-PROJECT'
TRAINED_MODEL = 'YOUR-MODEL'

GOOGLE_SERVICE_EMAIL = 'YOURSERVICEEMAIL@developer.gserviceaccount.com'
GOOGLE_PROJECT_KEY = 'YOURKEY.p12'


def hist(file)
  iplimg = OpenCV::IplImage.decode_image(open(file).read)
  b, g, r = iplimg.split

  dim = 3
  sizes = [8,8,8]
  ranges = [[0, 255],[0, 255],[0, 255]]
  hist = OpenCV::CvHistogram.new(dim, sizes, OpenCV::CV_HIST_ARRAY, ranges, true)
  hist.calc_hist([r, g, b])
end

client = Google::APIClient.new(
  :application_name => 'Example Ruby application',
  :application_version => '1.0.0'
)

prediction = client.discovered_api('prediction', 'v1.6')

key = Google::APIClient::PKCS12.load_key(GOOGLE_PROJECT_KEY, "notasecret")
asserter = Google::APIClient::JWTAsserter.new(GOOGLE_SERVICE_EMAIL,
  ['https://www.googleapis.com/auth/prediction','https://www.googleapis.com/auth/devstorage.full_control'],
  key)
client.authorization = asserter.authorize() 

file = ARGV[0]

puts "Detecting game for #{file}"

h = hist(file)
vals = []

(0..511).each do |i|
  vals << h[i]
end

input = prediction.trainedmodels.predict.request_schema.new
input.input = {}
input.input.csv_instance = vals
result = client.execute(
  :api_method => prediction.trainedmodels.predict,
  :parameters => {'id' => TRAINED_MODEL, 'project' => PROJECT},
  :headers => {'Content-Type' => 'application/json'},
  :body_object => input
)

res = JSON.parse(result.body)

puts "\nResult: #{res["outputLabel"]}"
puts "\n#{res["outputMulti"][0]["label"]}: #{res["outputMulti"][0]["score"]}"
puts "#{res["outputMulti"][1]["label"]}: #{res["outputMulti"][1]["score"]}"
puts "#{res["outputMulti"][2]["label"]}: #{res["outputMulti"][2]["score"]}"
puts "#{res["outputMulti"][3]["label"]}: #{res["outputMulti"][3]["score"]}"
puts "#{res["outputMulti"][4]["label"]}: #{res["outputMulti"][4]["score"]}"
