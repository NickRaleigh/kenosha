require 'fileutils'
require 'nokogiri'
require 'active_support/core_ext'
require 'open-uri'

def app_settings
  settings = {
    "file" => "5-objects/_object.columns.scss",
    "templates" => [
      'http://localhost:8080'
    ]
  }
  settings
end

def read_templates(paths)
  paths.each do |path|
    open_template(path)
  end
end

def open_template(path)
  fh = open(path)
  html = fh.read
  sass_settings = []
  html.each_line do |line|
    if line.include?('o-columns--')
      line = line.gsub('" >', '').gsub(' ', '').gsub('">', '').gsub('"', '')
      sass_settings.push(line)
    end
  end

  parse_sass_settings(sass_settings)

end

def parse_sass_settings(settings)
  if settings.is_a?(Array)
    settings.each do |setting|
      parse_to_sass(setting)
    end
  end
end

def parse_to_sass(setting)
  if setting =~ /\d/         
    columns = ''
    layout = ''
    gaps = []
    breakpoint = ''

    columns = setting.scan(/o-columns--([0-9]+)-/)[0][0]

    #parse the rest of the settings
    remaining = setting.gsub(/o-columns--([0-9]+)-/, '')
    remaining = remaining.gsub(')(', ' ')
    remaining = remaining.gsub('(', '')
    remaining = remaining.gsub(')', '')
    remaining = remaining.split

    #layout
    layout = remaining[0]

    #gaps
    spacingGaps = remaining[1]
    if spacingGaps.include?(',')
      gaps = spacingGaps.split(',')
    else 
      gaps[0] = spacingGaps
      gaps[1] = spacingGaps
    end

    #breakpoint
    if remaining.length == 3
      breakpoint = remaining[2]
    end

    write_settings(columns,layout,gaps,breakpoint)
  else
    remaining = setting.gsub('o-columns--(', '').gsub(' ', '').gsub(')(', ' ').gsub(')', '').split(' ')
    if remaining.length == 2
      breakpoint = remaining[1]
    end
    layout = remaining[0]
    write_settings(0, layout, ['0','0'], breakpoint)
  end
end

def write_settings(columns,layout,gaps,breakpoint)
  xGap = gaps[0]
  yGap = gaps[1]
  if yGap.include?('~')
    yGap = '"' + yGap + '"'
  end
  if xGap.include?('~')
    xGap = '"' + xGap + '"'
  end
  print_string = "@include makeColumnSystem(#{columns}, '#{layout}', #{xGap}, #{yGap}, '#{breakpoint}');"

  file = app_settings['file']

  if not File.read(file).include?(print_string)
    open(file, 'a') { |f|
      f.puts print_string
    }
  end


end

def app
  settings = app_settings
  read_templates(settings['templates'])
end

app
