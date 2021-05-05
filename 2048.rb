['board', 'graphics'].each{|script| require_relative script}
['io/console', 'colorize'].each{ |g| require g }

class GameRunner


  @achievements = {
    16     => 'Unlock the 16 Tile',
    32     => 'Unlock the 32 Tile',
    64     => 'Unlock the 64 Tile',
    128    => 'Unlock the 128 Tile',
    256    => 'Unlock the 256 Tile',
    512    => 'Unlock the 512 Tile',
    1_024  => 'Unlock the 1024 Tile',
    2_048  => 'Unlock the 2048 Tile',
    4_096  => 'Unlock the 4096 Tile',
    8_192  => 'Unlock the 8192 Tile',
    16_384 => 'Unlock the 16384 Tile',
    "Score 500"     => 'Earn more than 500 points',
    "Score 1000"    => 'Earn more than 1000 points',
    "Score 2000"    => 'Earn more than 2000 points',
    "Score 5000"    => 'Earn more than 5000 points',
    "Score 10000"   => 'Earn more than 10000 points',
    "HIGHEST SCORE" => 'Earn more than 20000 points'
  }

  @unlocked   = []
  @scores     = [0]
  @tiles      = [16, 32, 64, 128, 256, 512, 1_024, 2_048, 4_096, 8_192, 16_384]
  @numbers    = [0, 2, 4, 8].concat(@tiles)
  @milestones = [500, 1_000, 2_000, 4_000, 8_000, 16_000]
  @board      = Board.new

  def initialize
  end

  def game_score
    @board.getBoard.flatten.inject(:+)
  end

  def high_score
    [game_score, @scores.max].max
  end

  def receive_input
    input = ''
    controls = %w(a s d w)
    until controls.include?(input)
      input = STDIN.getch
      abort 'escaped' if input == "\e"
    end
    input
  end

  def make_move
    direction = receive_input

    case direction
    when 'a' then action = @board.moveLeft
    when 'd' then action = @board.moveRight
    when 'w' then action = @board.moveUp
    when 's' then action = @board.moveDown
    end

    @board.newTile if action
  end

  def get_tiles
      2.times { @board.newTile }
    draw_board
  end

  def move_sequence
    until @board.winChecker

      make_move
      draw_board

      if @board.lossChecker
        @win = false
        break
      end

    end
  end

  def unlock_tiles
    @tiles.each do |tile|
      unless @unlocked.include?(@achievements[tile])
        @unlocked << @achievements[tile] if (@board.getBoard.flatten.include?(tile))
      end
    end
  end

  def reach_milestones
    @milestones.each do |milestone|
      unless @unlocked.include?(@achievements["Score #{milestone}"])
        @unlocked << @achievements["Score #{milestone}"] if game_score >= milestone
      end
    end
  end

  def highest_honor
    unless @unlocked.include?(@achievements['HIGHEST SCORE'])
      @unlocked << @achievements['HIGHEST SCORE'] if game_score >= 20_000
    end
  end

  def earn_achievements
    unlock_tiles
    reach_milestones
    highest_honor
  end

  def play
    greeting
    get_tiles
    move_sequence
  end

  def play_cycle
    play
    earn_achievements
    end_game
  end

  def run
    play_cycle                                                  # Starts the game

    response = ''

    while response == '' || response == 'y'
      puts "\t\t HIGH SCORE: #{@scores.max}\n"
      @board = Board.new
      puts "\n\t\t Would you like to play again?"
      puts "\t\t Press y for 'Yes' and n for 'No'"
      response = gets.chomp

      # A list of the achievements they've earned will show up

      while response == 'a'
        puts "\n\t\t ACHIEVEMENTS \n\n"
        @unlocked.each { |a| puts "\t\t " << a }
        puts "\n"
        response = ''
      end

      play_cycle if response == 'y'

    end
  end

  def draw_board
    show_score
    (0..3).each do |x|
      print "\t\t| "
      (0..3).each { |y| print colorize_number(@board.getBoard[x][y]) << '| ' }
      puts ''
    end
    puts ''
  end

  def greeting
    puts "\n\t\t Welcome to 2048!"
    puts "\n\t\t RULES"
    puts "\n\t\t Match powers of 2 by connecting ajacent identical numbers."
    puts "\n\t\t CONTROLS"
    puts "\n\t\t a - Move left"
    puts "\t\t d - Move right"
    puts "\t\t w - Move up"
    puts "\t\t s - Move down"
    puts "\n"
  end

  def win_message
    puts "\t\t Congratulations! You reached the FINAL tile!".yellow
  end

  def lose_message
    puts "\t\t There are no more ajacent tiles with the same number.".red
    puts "\t\t The game is over".red
  end

  def game_over_message
    puts "\n\t\t Your final score was #{game_score}."
    puts "\n\t\t Press 'a' to view your achievements!\n"
  end

  def end_game
    @win ? win_message : lose_message
    game_over_message
    @scores << game_score
  end

  @colors     = %i(white white light_red red light_yellow yellow light_cyan
                cyan light_green green light_blue blue light_magenta magenta)

  def colorize_score
    game_score.to_s.yellow
  end

  def show_score
    puts "\t\t Score: #{game_score == high_score ? colorize_score : game_score} " <<
           "High Score: #{game_score == high_score ? colorize_score : high_score} " <<
           "Achievements: #{@unlocked.count}"
    puts "\t\t ________________________________________"
  end

  def colorize_number(num)
    number = '%4.4s' % num
    color = ''
    colors_array = [@numbers.zip(@colors)].flatten(1)

    for i in 0..colors_array.length-1
      color = number.colorize(colors_array[i][1]) if num == colors_array[i][0]
    end

    color.underline
  end

end

GameRunner.new.run
