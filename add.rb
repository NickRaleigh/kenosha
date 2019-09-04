require 'fileutils'

def app_settings
  settings = {
    "file" => "index.scss",
    "open" => "true",
    "editor" => "nvim"
  }
  settings
end

def welcome 
  puts "Select an option:"
  puts "1 - Setting"
  puts "2 - Tool"
  puts "3 - Generic"
  puts "4 - Element"
  puts "5 - Object"
  puts "6 - Component"
  puts "7 - Utility"
  gets.to_i
end

def get_name
  puts "enter the name(without o- or c- prefix)"
  gets.chomp
end

def get_prefix(mode)
  prefix = {
    "setting" => "setting",
    "tool" => "tool",
    "generic" => "generic",
    "element" => "element",
    "object" => "o",
    "component" => "c",
    "utility" => "utility",
  }
  prefix[mode]
end

def lookup(num)
  index = {
    1 => "setting",
    2 => "tool",
    3 => "generic",
    4 => "element",
    5 => "object",
    6 => "component",
    7 => "utility",
  }
  if index[num]
    return index[num]
  else
    puts 'Incorrect input'
    exit!
  end
end

def get_plural(mode) 
  plural = {
    "setting" => "settings",
    "tool" => "tools",
    "generic" => "generic",
    "element" => "elements",
    "object" => "objects",
    "component" => "components",
    "utility" => "utilities"
  }
  plural[mode]
end

def update_stylesheet(name, choice, mode, index)
  if File.exists?(index)
    plural = get_plural(mode)
    upcase = mode.upcase
    text = File.read(index)
    new_lines = <<~SCSS
      @import './#{choice}-#{plural}/#{mode}.#{name}';
      // ---#{upcase} - PLACHOLDER --- //
    SCSS
    placeholder_line = "// ---#{upcase} - PLACHOLDER --- //"
    updated_file = text.gsub(/#{placeholder_line}/, new_lines)
    File.open(index, "w") {|file| file.puts updated_file }
  end
end

def create_file(name, choice, mode)
  plural = get_plural(mode)
  target_file = "./#{choice}-#{plural}/_#{mode}.#{name}.scss" 
  if !File.exists?(target_file)
    FileUtils.touch(target_file)
  else
    Puts "#{mode} already exists"
    kill!
  end
  target_file
end

def update_new_file(text, name, mode)
    if mode == "object" || mode == "component"
      prefix = get_prefix(mode)
      new_lines = <<~SCSS
        .#{prefix}-#{name} {
          $this: '.#{prefix}-#{name}';
          @extend %bem-block;
          // PLACEHOLDER
        }
      SCSS
      File.open(text, "w") {|file| file.puts new_lines }
    end
    text
end

def build_children(mode, name, text)
  if mode == "object" || mode == "component"
    puts "Add children to #{mode}? Separate with spaces, otherwise leave empty."
    children = gets.chomp.split(' ')
    if children != ''
      children_template = ''
      children.each do |child|
        children_template += <<~SCSS

            \t&__#{child} {
            \t}
        SCSS
      end
    else
      children_template = ''
    end
      doc = File.read(text)
      placeholder_line = "// PLACEHOLDER"
      updated_file = doc.gsub(/#{placeholder_line}/, children_template)
      File.open(text, "w") {|file| file.puts updated_file }
  end
end

def open(set_to_open, editor, new_file)
  if set_to_open
    system("#{editor}", "#{new_file}")
  end
end

def app 
  settings = app_settings
  choice = welcome
  mode = lookup(choice)
  name = get_name
  new_file = create_file(name, choice, mode)
  update_stylesheet(name, choice, mode, settings['file'])
  update_new_file(new_file, name, mode)
  build_children(mode, name, new_file)
  open(settings['open'], settings['editor'], new_file)
end

app
