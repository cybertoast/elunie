#!/bin/env ruby

require 'YAML'
require 'pp'

# require "test/unit"
# class TestElunie < Elunie
#     def test_generateRule
#     end
# end

class Elunie    
    # Declare the accessors even just to remember!
    attr_accessor :CONFIG
    attr_accessor :RuleSet
    attr_accessor :CurrentRule
    attr_accessor :Previous
    
    def initialize(configFile="config.yaml")
        # load configuration
        @CONFIG = YAML.load_file(configFile)
    end

    def debug(data)
        if !@CONFIG['data']['debug']
            return
        end
        puts "Rule is: .."
        PP.pp(@RuleSet)
        puts
    end
    
    def showTip
        puts "The secret key:"
        print "IF ... "; PP.pp(@RuleSet['if'])
        print "CHOOSE ... "; PP.pp(@RuleSet['choose'])
        print "ELSE ... "; PP.pp(@RuleSet['else'])
        puts
    end
    
    def matchCurrentRule(previous, current)
        rule = @RuleSet
        # TODO: this should be a method-missing
        if rule['if']['value'] == previous[rule['if']['key']]
            if current[rule['choose']['key']] == rule['choose']['value']
                return true
            end
        else
            # Run the 'else' rule, which might be 'same' or 'different'
            if ( current[rule['else']['key']] == rule['else']['value'] ) ||
               ( rule['else']['value'] == 'same' && 
                 current[rule['else']['key']] == previous[rule['else']['key']] ) ||
               ( rule['else']['value'] == 'different' && 
                 current[rule['else']['key']] != previous[rule['else']['key']] )
                return true
            end
        end

        return false
    end

    def showExamples
        # Generate a random current
        data = @CONFIG['data']
        count = @CONFIG['data']['numberOfExamples']
        examples = []
        
        # Always start with a working example
        previous = { 'size' => data['sizes'][rand(data['sizes'].length)],
                     'color' => data['colors'][rand(data['colors'].length)],
                     'figure' => data['figures'][rand(data['figures'].length)],
                    }

        # Need a list of unique examples
        while examples.length < count
            current = { 'size' => data['sizes'][rand(data['sizes'].length)],
                        'color' => data['colors'][rand(data['colors'].length)],
                        'figure' => data['figures'][rand(data['figures'].length)],
                    }
            examples.push current
            examples = examples.uniq
            if matchCurrentRule(previous, current)
                previous = current
            end
        end

        debug(@RuleSet)

        puts "The first " + @CONFIG['data']['numberOfExamples'].to_s + " moves are:"
        examples.each do |example|
            puts [example['size'], example['color'], example['figure']].join(' ')
        end
        
        # Globalize the previous since we'll need it later
        @Previous = previous
    end
    
    def generateRule()
        # Create a random list of CONFIG[numberOfRules] rules
        # by randomly selecting an item from each list
        len = @CONFIG['rules'].length

        @RuleSet = @CONFIG['rules'][len]
        
    end
    
    def play
        self.generateRule

        puts @CONFIG['prompts']['welcome']
        self.showExamples
        puts
        self.promptUser
    end
    
    def menu
        puts "--------------------------------------------------"
        puts "Instructions for this game are as follows: "
        puts "h/? : help"
        puts "q/x : exit"
        puts "tip : get secret tips"
        puts
        puts "size color figure : to try your luck at the game"
        puts "That's all for now"
        puts "--------------------------------------------------"
    end
    
    def promptUser()        
        until false do
            puts @CONFIG['prompts']['start']
            ans = gets.chomp

            case ans
            when /^[\?h]$/i
                menu
            when /^[xq]$/i
                exit 0
            when /^tip$/
                showTip
            else
                # ans needs to be split into size, color, shape
                size, color, figure = ans.split
                current = {'figure' => figure, 'color' => color, 'size' => size}
                if matchCurrentRule(@Previous, current)
                    puts @CONFIG['prompts']['correct']
                    @Previous = current
                else
                    puts @CONFIG['prompts']['incorrect']
                end

            end
        end
        
    end
end 
