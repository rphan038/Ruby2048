class Board
    # Tile inner class. The Board class is composed of many instances of Tile
    class Tile
        @@tileTypes = [0, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048]
        @value
        # Comparable mixin
        include Comparable
        def initialize(val)
            if @@tileTypes.include?(val)
                @value = val
            else
                @value = -1
            end
        end

        #Like the compareTo method in Java
        def <=> (other)
            @value <=> other.getTileVal
        end

        def getTileVal
            return @value
        end

        def setTileVal(newVal)
            @value = newVal
        end

        def isValidTile
            if @value != -1
                return true
            end
            return false
        end

        def mult(x)
            if isValidTile
                @value *= x
            end
        end

        def plus(x)
            if isValidTile
                @value += x
            end
        end
    end

    # Board Instance Variable
    @board

    # Board Constructor
    def initialize
        @board = Array.new(4) { [Tile.new(0), Tile.new(0), Tile.new(0), Tile.new(0)] }
        # Board that does not have any moves left --> for testing
        # @board = [[Tile.new(2), Tile.new(16), Tile.new(4), Tile.new(2)], 
        # [Tile.new(4), Tile.new(64), Tile.new(16), Tile.new(4)], 
        # [Tile.new(8), Tile.new(4), Tile.new(32), Tile.new(8)], [
        #     Tile.new(2), Tile.new(8), Tile.new(16), Tile.new(4)]]
    end

    # Getter method for the BOARD instance variable
    def getBoard
        @board
    end

    # Helper method for the move methods
    def flipBoard
        @board.transpose.map(&:reverse)
    end

    # Move all tiles left one index if possible. If the tile is on the leftmost column, stay there
    def shift_left(line)
        new_line = []
        line.each { |line| new_line << line unless line.getTileVal.zero? }
        new_line << Tile.new(0) until new_line.size == 4
        new_line
    end

    def moveLeft
        new_board = Marshal.load(Marshal.dump(@board))
        (0..3).each do |i|
            (0..3).each do |j|
                (j..2).each do |k|
                    if @board[i][k + 1].getTileVal == 0
                        next
                    elsif @board[i][j].getTileVal == @board[i][k + 1].getTileVal
                        @board[i][j].mult(2)
                        @board[i][k + 1].setTileVal(0)
                    end
                    break
                end
            end
            @board[i] = shift_left(@board[i])
        end
        @board == new_board ? false : true
    end

    def moveRight
        @board.each(&:reverse!)
        action = moveLeft
        @board.each(&:reverse!)
        action
    end

    def moveDown
        @board = flipBoard
        action = moveLeft
        3.times { @board = flipBoard }
        action
    end

    def moveUp
        3.times { @board = flipBoard }
        action = moveLeft
        @board = flipBoard
        action
    end

    # Checks to see whether the player has won
    def winChecker
        @board.flatten.max.getTileVal == 2048
    end

    # Checks the board to see whether there are no more legal moves
    def lossChecker
        new_board = Marshal.load(Marshal.dump(@board))
        option = moveRight || moveLeft || moveUp || moveDown
        unless option
          @board = Marshal.load(Marshal.dump(new_board))
          return true
        end
    
        @board = Marshal.load(Marshal.dump(new_board))
        false
    end

    # Changes the value of every tile on the board to 0
    def resetBoard
        (0..3).each do |x|
            (0..3).each { |y| @board[x][y].setTileVal(0) }
        end
    end

    # Converts the board to a string
    def stringify
        str = ""
        (0..3).each do |x|
            str << "\t\t| "
            (0..3).each { |y| str << @board[x][y].getTileVal.to_s << '| ' }
            str << "\n"
        end
        return str
    end

    # Generates a new tile where there is a tile with value 0
    def newTile
        tile = [*1..2].sample * 2
        x = [*0..3].sample
        y = [*0..3].sample
        (0..3).each do |i|
            (0..3).each do |j|
                x1 = (x + i) % 4
                y1 = (y + j) % 4
                if @board[x1][y1].getTileVal == 0
                    @board[x1][y1].setTileVal(tile)
                    return true
                end
            end
        end
    end

    #temporary --> for testing/debugging purposes
    def draw_board
        (0..3).each do |x|
          print "\t\t| "
          (0..3).each { |y| print @board[x][y].getTileVal.to_s << '| ' }
          puts ''
        end
        puts ''
    end
end

# #Testing
# t = Board::Tile.new(2)
# t1 = Board::Tile.new(4)
# puts t.getTileVal
# puts t.isValidTile
# puts t.mult(4)
# puts t > t1
#
# b = Board.new
# b.draw_board
# b.resetBoard
# b.newTile
# puts b.stringify
