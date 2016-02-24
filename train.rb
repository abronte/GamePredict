require 'liblinear'

# reference
# games = {1 => "csgo", 2 => "dota2", 3 => "hearthstone", 4 => "minecraft", 5 => "starcraft"}

# Setting parameters
param = Liblinear::Parameter.new
param.solver_type = Liblinear::L2R_LR

label_ids = {}

labels = []
examples = []

id = 1

File.open("training_set.txt", "r").each_line do |line|
  split = line.split(",")
  game = split[0].gsub("\"", "")

  if label_ids[game].nil?
    label_ids[game] = id
    id += 1
  end

  labels << label_ids[game]

  examples << split[1..-1].map{|x| x.to_f}
end

puts examples[0]

bias = 0.5
prob = Liblinear::Problem.new(labels, examples, bias)
model = Liblinear::Model.new(prob, param)

model.save("games.model")
