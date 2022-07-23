# frozen_string_literal: ture

require 'yaml'

class Game
  # ５から１２文字の単語をランダムに返す関数
  def make_random_word
    words = []
    path = 'google-10000-english-no-swears.txt'
    File.open(path, 'r') do |f|
      f.each do |line|
        line = line.strip
        words.push(line) if line.length >= 5 && line.length <= 12
      end
    end
    words.sample
  end

  def initialize
    @game_count = 27
    @correct_chars = []
    @answer = make_random_word
  end

  # 今まで受け取った単語の中で正解のものを表示する関数
  def show_correct_chars(correct_chars)
    word = ''
    @answer.split('').each do |char|
      word += if correct_chars.include?(char)
                "#{char} "
              else
                '_ '
              end
    end
    puts word
  end

  # 文字がアルファベットか確認する関数
  def alphabet?(char)
    alphabet_array = []
    ('a'.ord..'z'.ord).each do |num|
      alphabet_array.push(num.chr)
    end
    alphabet_array.include?(char)
  end

  # ゲームをセーブして終了する関数
  def save_game
    YAML.dump(self, File.open('save.yml', 'w'))
    puts 'Saved'
    exit
  end

  # 受け取った文字が適切なものか確認する関数
  def validate_input
    input = nil
    loop do
      puts 'Type a letter or type "save" if you want to continue later.'
      print 'Letter: '
      begin
        input = gets.strip.downcase
      rescue Interrupt
        puts "\n"
        exit
      else
        # saveと入力された場合はセーブする
        save_game if input == 'save'

        break if input.length == 1 && alphabet?(input)

        puts 'Invalid input'
        show_correct_chars(@correct_chars)
      end
    end
    input
  end

  # 文字列の判定をする関数
  def check_decision(letter)
    if @answer.include?(letter)
      if @correct_chars.include?(letter)
        puts "#{letter} is already exists"
      else
        @correct_chars.push(letter)
        puts 'Correct!'
      end
    else
      @game_count -= 1
      puts 'Incorrect'
    end
  end

  # すべての正解の文字が出揃ったか判定する関数
  def check_all_correct
    @answer.split('').all? { |chr| @correct_chars.include?(chr) }
  end

  # ゲームをプレイする関数
  def play
    loop do
      # 今まで受け取った中で正解の文字と残機を表示
      show_correct_chars(@correct_chars)
      puts "#{@game_count} times you can mistake!"
      # 文字を受け取り、適切なものか確認
      letter = validate_input
      # 文字が正解の単語の中に含まれていれば、配列に追加
      check_decision(letter)
      # ゲームカウントが０もしくは答えが完成した場合、終了
      if @game_count.zero?
        puts 'Game over!'
        puts "The answer is \"#{@answer}\""
        break
      end
      if check_all_correct
        puts "Correct all! The answer is \"#{@answer}\""
        break
      end
    end
  end

  private

  attr_accessor :answer, :game_count, :correct_chars
end

# プレイヤーの選択により、ゲームをロードするかどうか決める
loop do
  puts 'Type Enter to play new game or type load to continue last game.'
  begin
    players_select = gets.strip
  rescue Interrupt
    puts "\n"
    exit
  end
  # プレイヤーの選択
  if players_select == ''
    puts 'New game starts!'
    game = Game.new
    game.play
    break
  elsif players_select.downcase == 'load'
    puts 'Loading last game!'
    begin
      game = YAML.load_file(
        'save.yml',
        permitted_classes: [Game]
      )
    rescue Errno::ENOENT
      puts 'There is no save data.'
    else
      game.play
      break
    end
  else
    puts 'Invalid input'
  end
end
