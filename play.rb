require 'elunie'     

game = Elunie.new(configFile="elunie.yaml")
game.play()
puts game.CONFIG['rules']