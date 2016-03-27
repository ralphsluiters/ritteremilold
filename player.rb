class Player
  attr_accessor :score
  attr_reader :gewonnen
  attr_reader :verloren
  attr_reader :waffen
  attr_reader :schilde
  attr_reader :schluessel_blau
  attr_reader :helm


  def initialize(level,items)
    @items = items
    @sound_dig = Gosu::Sample.new("media/dig.mp3")
    @sound_wall = Gosu::Sample.new("media/wall.mp3")
    @sound_ziel = Gosu::Sample.new("media/ziel.mp3")
    @sound_schatz = Gosu::Sample.new("media/treasure.mp3")

    @x, @y = level.hero_start_position
    @score = 0
    @level = level
    @waffen = @schilde = 0
    @schluessel_blau = 0
    @gewonnen = @verloren = false
    @helm = false
  end


  def try_move(direction)
    x = @x ; y = @y
    case direction
    when :up
      y-= 1
    when :down
      y+= 1
    when :left
      x-= 1
    when :right
      x+= 1
    end

    case @level.value(x,y)
    when :mauer
      @sound_wall.play
    when :burg
      @sound_ziel.play
      @gewonnen = true
    when :stein
      move(x,y) if @level.try_push(x,y,direction, :stein)
    when :ork
      if @waffen > 0
        move(x,y)
        @waffen -=1
      else
        die!
      end
    when :btuer
      if @schluessel_blau > 0
        move(x,y)
        @schluessel_blau -= 1
      end

    when :lava
      die!
    when :schatz
      @sound_schatz.play
      @level.add_animation(:schatz,x,y)
      @score +=100
      move(x,y)
    when :helm
      @sound_schatz.play
      @helm = true
      @level.add_animation(:helm,x,y)
      move(x,y)
    when :erde
      @sound_dig.play
      move(x,y)
    when :bkey
      @schluessel_blau +=1
      @level.add_animation(:bkey,x,y)
      move(x,y)
    when :axt
      @waffen +=1
      @level.add_animation(:axt,x,y)
      move(x,y)
    when :schild
      @schilde +=1
      @level.add_animation(:schild,x,y)
      move(x,y)
    else
      move(x,y)
    end
  end

  def move(x,y)
    @x=x; @y=y
    @level.clean_position(x,y)
    @level.scroll_to(x,y)
  end

  def on_position?(x,y)
    x==@x && y==@y
  end

  def die!
    @verloren = true
  end

  def attacked
    if @schilde > 0
      @schilde -= 1
    else
      die!
    end
  end


  def draw(scroll_x,scroll_y)
    @items.draw(:ritter,@x,@y,scroll_x,scroll_y)
  end


end