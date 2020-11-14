require 'csv'

class Event
  attr_reader :type, :title, :place, :period, :description, :picture_path, :compressed_path, :url, :id

  def self.create_list_from_csv(csv_filename)
    events = CSV.read(csv_filename, headers: true, encoding: 'UTF-8').map(&:to_h).map.with_index do |row, index|
      period = Period.create_from_day_and_time(row['start_day']&.strip, row['start_at']&.strip, row['end_day']&.strip, row['end_at']&.strip)
      type_str = if row['type'] == "0" then "regular" elsif row['type'] == "1" then "permanent" else "guerrilla" end
      image_dir = if row['type'] == "0" then row['start_day'] elsif row['type'] == "1" then "permanent" else "guerrilla" end
      self.new(row['id']&.strip, type_str, row['title']&.strip, row['place']&.strip, period, row['details']&.strip,
        "images/#{image_dir}/#{row['path']}.#{row['ext']}", "images/0000/#{row['path']}.#{row['ext']}", nil)
    end
    {
      regulars: events.select { |event| event.type == 'regular' },
      guerrillas: events.select { |event| event.type == 'guerrilla' },
      permanents: events.select { |event| event.type == 'permanent' }
    }
  end

  def initialize(index, type, title, place, period, description, picture_path, compressed_path, url)
    @id = index
    @type = type
    @title = title
    @place = place
    @period = period
    @description = description
    @picture_path = picture_path
    @compressed_path = compressed_path
    @url = url
  end

  def period_formatted
    if regular?
      period.formatted
    elsif permanent?
      '常時開催'
    else
      '？'
    end
  end

  def description
    @description || '？'
  end

  def place
    @place || '？'
  end

  ['regular', 'guerrilla', 'permanent'].each do |type_string|
    define_method :"#{type_string}?" do
      type == type_string
    end
  end
end

def combine_day_and_time_str(day_str, time_str)
  if !day_str.nil? && !time_str.nil?
    month = day_str[0..1].to_i
    day = day_str[2..3].to_i
    hour, minute = time_str.split(':').map(&:to_i)
    Time.local(2020, month, day, hour, minute)
  end
end

class Period
  def self.create_from_day_and_time(start_day_str, start_at_str, end_day_str, end_at_str)
    if !start_day_str.nil?
      start_day = Date.new(2020, start_day_str[0..1].to_i, start_day_str[2..3].to_i)
      end_day = Date.new(2020, end_day_str[0..1].to_i, end_day_str[2..3].to_i)
      self.new(start_day, start_at_str, end_day, end_at_str)
    else
      self.new(nil, nil, nil, nil)
    end
  end

  def initialize(start_day, start_at, end_day, end_at)
    @start_day = start_day
    @start_at = start_at
    @end_day = end_day
    @end_at = end_at
  end

  def date
    @start_day
  end

  def formatted
    format_string = '%m月%d日 '
    "#{@start_day&.strftime(format_string)}#{@start_at} 〜 #{@end_day&.strftime(format_string)}#{@end_at}"
  end

  def day_formatted
    youbi = %w[日 月 火 水 木 金 土][@start_day.wday]
    date.strftime("%m月%d日（#{youbi}）")
  end
end
