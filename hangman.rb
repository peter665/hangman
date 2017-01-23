require 'json'

class Hangman
  attr_accessor :word, :solution, :letter, :misses

  def initialize
    @word = self.random_word
    @solution = Array.new(@word.size)
    @misses = []
  end

#Loading a dictionary and choosing a random word of 5 to 12 lenght

  def random_word
    new_dict =[]
    File.readlines('dictionary.txt').each do |line|
      new_dict.push line if line.length.between?(6,13) #because of a new line char
    end
    random_word = new_dict[rand(1..new_dict.size)].downcase.strip.split("")
  end

  def play
    load_game   #Welcom message and an option to load a saved game
    while true do #Play until win or loose
      guess     #Player can guess a letter, if he guessed right every occurence of the letter is put to the solution array on its right positon
      draw_word #The solution array is output to the screen, blanks represented with "_". Also the misses array is output.
      win_loose #This checks if the player solved the game - when the SOLUTION array equals the random WORD array or wether he run out of guesses
      save      #An option to save the game after every round of guessing in a txt file
    end
  end

#Serialization into json
  def to_json
    {'word' => @word, 'solution' => @solution, 'letter' => @letter, 'misses' => @misses}.to_json
  end

#Deserialization from json
  def from_json str
    data = JSON.parse(str)
    self.word = data['word']
    self.misses = data['misses']
    self.solution = data['solution']
    self.letter = data['letter']
  end

  def load_game
    puts %{Welcome! This is the Hangman game. Good luck!}
    print "Would you like to load one of your saved games?(y/n) "
    a = gets.chomp.downcase
    if a == 'y'
      puts "Your saved games:"
      Dir.glob(Dir.pwd + '/saves/*').each do |file|
        puts file.match(/\w+.txt$/)
      end
      print "File to load: "
      f = gets.chomp
      if File.exists?('saves/' + f)
        file = File.read("saves/" + f)
        from_json(file)
        draw_word
      else
        puts "The filename you entered does not exists"
        puts "Starting a new game."
        return
      end
    end
    puts "------------------------------------------------------------"
  end

  def save
    print "Would you like to save this game?(y/n) "
    if gets.chomp.downcase == 'y'
      obj = self.to_json
      print "Name of your save: "
      name = gets.chomp
      File.open('saves/' + name + '.txt', 'w') do |f|
        f.write(obj)
      end
      puts "------------------Game saved!---------------------"
    end
    puts "--------------------------------------------------"
  end

  def draw_word
    print "Word: \t"
    @solution.each do |letter|
      if letter == nil
        print "_"
      else
        print letter
      end
    end
    puts
    puts "Guess: " + @letter
    print "Misses: "
    @misses.each do |el|
      print el + ','
    end
    puts
    puts "You have #{6-@misses.size} guesses left!"
    puts "----------------------------------------------"
  end

  def guess
    print "Please guess a letter! "
    @letter = gets.chomp.downcase
    for i in 0...@word.length do
      if @word[i] == @letter
        @solution[i] = @letter
      end
    end
    @misses.push(@letter) if !@word.include?(@letter)
  end

  def win_loose
    if @word == @solution
      puts "Congratulations, you have solved it!"
      abort
    end
    if @misses.size >= 6
      puts "You have lost, you already guessed 6 times."
      puts "The answer was: #{@word.join("")}"
      abort
    end
  end
end

h = Hangman.new.play
