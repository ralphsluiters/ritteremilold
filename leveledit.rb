require 'gosu'

module ZOrder
  Background, Game, UI = *0..2
end

require_relative 'items'
require_relative 'level'
require_relative 'dialog'




class GameWindow < Gosu::Window
  def initialize(level_nummer)
    super(32*25+20, 32*20+20+20+32+20)#, fullscreen: true )
    self.caption = "Ritter Emil - Leveleditor"
    @background_image = Gosu::Image.new("media/boden.jpg", :tileable => true)
    @items = Items.new(nil)
    @new_level_width = 25
    @new_level_height = 20

    if level_nummer.to_i>0 #given level as parameter
      @level_nummer = level_nummer.to_i
      @level = Level.new(@level_nummer,@items,true)
      @level.load_level
      @level.scroll_to(0,0)
      @state_machine = :level_edit_start
    else
      @level_nummer = 1
      @level = Level.new(@level_nummer,@items,true)
      @state_machine = :new_game
    end
    @dialog = Dialog.new(self)
    @position = Position.new(@items, @level)
    @font_small = Gosu::Font.new(20)

  end

  def update
    if @wait_end
      if Gosu::milliseconds > @wait_end || Gosu::button_down?(Gosu::KbSpace)
        @state_machine = @next_state
        @wait_end = nil
      end
    else

      case @state_machine
      when :level_edit
        if Gosu::button_down? Gosu::KbLeft
          @position.move(@position.x-1,@position.y)
          sleep 0.2
        end
        if Gosu::button_down? Gosu::KbRight
          @position.move(@position.x+1,@position.y)
          sleep 0.2
        end
        if Gosu::button_down? Gosu::KbUp
          @position.move(@position.x,@position.y-1)
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbDown)
          @position.move(@position.x,@position.y+1)
          sleep 0.2
        end

        if Gosu::button_down?(Gosu::KbY)
          @position.move_key(@position.key_pos-1)
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbX)
          @position.move_key(@position.key_pos+1)
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbSpace)
          @level.set_position!(@position.x,@position.y,@position.key)
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbN)
          @new_level_width=25
          @new_level_height=20
          @state_machine = :new_game
        end
        if Gosu::button_down?(Gosu::KbS)
          @state_machine = :save_game
        end
        if Gosu::button_down?(Gosu::KbL)
          @state_machine = :load_game
        end
      when :level_edit_start
        wait_time(2,:level_edit)
      when :save_game
        if Gosu::button_down? Gosu::KbLeft
          @level.change_number(-1)
          sleep 0.2
        end
        if Gosu::button_down? Gosu::KbRight
          @level.change_number(+1)
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbEnter) || Gosu::button_down?(40)
          @level.save_level
          @state_machine = :level_edit
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbEscape)
          @state_machine = :level_edit
          sleep 0.2
        end
      when :new_game
        if Gosu::button_down? Gosu::KbLeft
          @new_level_width -=1 if @new_level_width >3
          sleep 0.2
        end
        if Gosu::button_down? Gosu::KbRight
          @new_level_width +=1 if @new_level_width <500
          sleep 0.2
        end
        if Gosu::button_down? Gosu::KbUp
          @new_level_height -=1 if @new_level_height >3
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbDown)
          @new_level_height +=1 if @new_level_height <500
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbEnter) || Gosu::button_down?(40)
          @level.new_level(@new_level_width,@new_level_height)
          @state_machine = :level_edit_start
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbEscape)
          @state_machine = :level_edit
          sleep 0.2
        end

      when :load_game
        if Gosu::button_down? Gosu::KbLeft
          @level.change_number(-1)
          sleep 0.2
        end
        if Gosu::button_down? Gosu::KbRight
          @level.change_number(+1)
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbEnter) || Gosu::button_down?(40)
          @level.load_level
          @state_machine = :level_edit
          sleep 0.2
        end
        if Gosu::button_down?(Gosu::KbEscape)
          @state_machine = :level_edit
          sleep 0.2
        end
      end

    end

    def draw
      case @state_machine
      when :level_edit
        @background_image.draw(0, 0, ZOrder::Background)
        @level.draw(@position)
        draw_items
        @font_small.draw("Level: #{@level.nummer}  | Größe: #{@level.breite}x#{@level.hoehe}  |  Q zum Beenden", 10, 0, ZOrder::UI,1,1,0xff_000000)
        @font_small.draw(@position.key || "Leer", 10, 20*32+20+20+32, ZOrder::UI,1,1,0xff_000000)
        (0..[19,@level.hoehe].min).each {|y| @font_small.draw(y+@level.scroll_y+1,25*32+1, 20+6+y*32, ZOrder::UI,1,1,0xff_000000)}
        (0..[24,@level.breite].min).each {|x| @font_small.draw(x+@level.scroll_x+1,6+x*32, 20*32+22, ZOrder::UI,1,1,0xff_000000)}
      when :new_game
        @dialog.show("Neues Level","Größe: #{@new_level_width}x#{@new_level_height}\nGröße mit Pfeiltasten ändern\nENTER zum Erstellen\nESC zum Abbrechen")
      when :load_game
        @dialog.show("Laden!","Level #{@level.nummer}\nPfeile um Levelnummer zu ändern\nENTER zum Laden\nESC zum Abbrechen")
      when :save_game
        @dialog.show("Speichern!","Level #{@level.nummer}\nPfeile um Levelnummer zu ändern\nENTER zum Speichern\nESC zum Abbrechen")
      when :level_edit_start
        @dialog.show("Leveleditor!","Y / X zum Wechseln der Items\nS zum Speichern\nL zum Laden\nN für neues Level\nQ zum Beenden")
      end
    end
  end

  def button_down(id)
    if id == Gosu::KbQ
      close
    end

  end

  def draw_items
    x = 0
    Items.drawable_items.each do |key|
      @items.draw_on_position(key,x,20*32+40,ZOrder::Game) if key
      x+=32
    end
  end


private
  def wait_time(seconds,next_state)
    @wait_end = Gosu::milliseconds + seconds*1000
    @next_state = next_state
  end

end

class Position
  attr_reader :x,:y
  attr_reader :key_pos
  def initialize(items, level)
    @x = @y = 0
    @items = items
    @level = level
    @key_pos = 0
  end
  def move(x,y)
    if @level.value(x,y) != :levelende
      @x=x; @y=y
      @level.scroll_to(x,y)
    end
  end
  def move_key(x)
    @key_pos = x
    @key_pos = Items.drawable_items.size-1 if x<0
    @key_pos = 0 if x >= Items.drawable_items.size
  end

  def key
    Items.drawable_items[@key_pos]
  end

  def draw(scroll_x,scroll_y)
    @items.draw(:selection,@x,@y,scroll_x,scroll_y)
    @items.draw_on_position(:selection,@key_pos*32,20*32+40,ZOrder::UI)
  end


end

# print "Bitte Levelnummer eingeben:"
# level_nummer = gets.to_i
# unless File.exist?("levels/level%03d.json" % level_nummer)
# end

window = GameWindow.new(ARGV[0])
window.show