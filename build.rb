require 'rakyll'
require './parses.rb'
require 'uri'

IMAGE_BASE_PATH = 'data'
CSV_PATH = './data/list2020.csv'

def all_events
  Event.create_list_from_csv(CSV_PATH).values.reduce(:+)
end

def regulars
  Event.create_list_from_csv(CSV_PATH)[:regulars]
end
def permanents
  Event.create_list_from_csv(CSV_PATH)[:permanents]
end
def guerrillas
  Event.create_list_from_csv(CSV_PATH)[:guerrillas]
end

Rakyll.dsl root_path: 'ryosai2020', watch: ARGV.include?('--watch') do
  copy 'assets/*'
  copy 'data/*.png'
  copy 'data/images/*/*.jpg'

  create 'index.html', dependencies: [CSV_PATH] do
    @title = '熊野寮祭'
    apply 'index.html.erb'
    apply 'default.html.erb'
  end

  create 'contact.html', dependencies: [CSV_PATH] do
    @title = 'お問い合わせ'
    apply 'contact.html.erb'
    apply 'default.html.erb'
  end

  create 'access.html', dependencies: [CSV_PATH] do
    @title = 'アクセス'
    apply 'access.html.erb'
    apply 'default.html.erb'
  end

  create 'contrib.html', dependencies: [CSV_PATH] do
    @title = '寄稿文'
    apply 'contrib.html.erb'
    apply 'default.html.erb'
  end

  create 'events.html', dependencies: [CSV_PATH] do
    @permanents = permanents
    @regulars = regulars
    @guerrillas = guerrillas
    @title = '企画一覧'
    apply 'events_index.html.erb'
    apply 'default.html.erb'
  end

  create 'guerrilla.html', dependencies: [CSV_PATH] do
    @title = 'ゲリラ企画'
    @events = guerrillas
    apply 'events.html.erb'
    apply 'default.html.erb'
  end

  create 'permanent.html', dependencies: [CSV_PATH] do
    @title = '常設企画'
    @events = permanents
    apply 'events.html.erb'
    apply 'default.html.erb'
  end

  regulars.map { |evt| evt.period.date }.uniq.each do |target_date|
    create "#{target_date}.html", dependencies: [CSV_PATH] do
      @title = "#{target_date.strftime('%m/%d')}(#{%w{日 月 火 水 木 金 土}[target_date.wday]})の企画"
      @events = regulars.select { |evt| evt.period.date == target_date }
      apply 'events.html.erb'
      apply 'default.html.erb'
    end
  end
end

Rakyll.dsl root_path: 'ryosai2020/events', watch: ARGV.include?('--watch') do
  all_events.each do |event|
    create "#{event.id}.html", dependencies: [CSV_PATH] do
      @title = "#{event.title}"
      @event = event
      apply 'event.html.erb'
      apply 'default_for_event.html.erb'
    end
  end
end
