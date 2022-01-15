# Подключаем класс Post и его детей
require_relative 'lib/post'
require_relative 'lib/memo'
require_relative 'lib/link'
require_relative 'lib/task'

# Как обычно, при использовании классов программа выглядит очень лаконично
puts 'Привет, я твой блокнот! Версия 2 + Sqlite'

# Теперь надо спросить у пользователя, что он хочет создать
puts 'Что хотите записать в блокнот?'

# массив возможных видов Записи (поста)
choices = Post.post_types.keys

choice = -1

until choice >= 0 && choice < choices.size # пока юзер не выбрал правильно выводим заново массив возможных типов поста
  choices.each_with_index do |type, index|
    puts "\t#{index}. #{type}"
  end
  choice = $stdin.gets.chomp.to_i
end

# выбор сделан, создаем запись с помощью стат. метода класса Post
entry = Post.create(choices[choice])

# Просим пользователя ввести пост
entry.read_from_console

# сохраняем запись в БД
id = entry.save_to_db

puts "Ура, запись сохранена, id = #{id}"
