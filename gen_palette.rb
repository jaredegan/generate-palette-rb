require 'RMagick'
include Magick

def is_img?(file)
  # Very simple 'image' verification
  fname = file.downcase
  fname.include?(".gif") or fname.include?(".png") or fname.include?(".jpg")
end

imgs = []

ARGV.each do |file|
  if File.directory?(file)
    Dir.entries(file).each do |f|
      imgs << "#{file}/#{f}" if is_img?(f)
    end
  else
    if (is_img?(file))
      imgs << file
    else
      puts "\"#{file}\" doesn't seem to be an image."
      exit
    end
  end
end

puts "Looking at files:"
imgs.each { |i| puts "  #{i}" }

colors = []

# Collect all the colors
imgs.each do |img|
  source = ImageList.new(img)
  puts "Opening #{img}"
  
  p = source.unique_colors

  puts "  #{p.columns} colors"

  for i in 0..p.columns
    c = p.pixel_color(i, 0)
    colors << c
  end
  
  colors.uniq! { |v|
    "#{v}"
  }
  puts "  #{colors.count} unique colors so far"

end

# Sort them. This could be better.
colors.sort! { |c1, c2|
  hue1 = c1.to_hsla[0]
  hue2 = c2.to_hsla[0]
  sat1 = c1.to_hsla[1]
  sat2 = c2.to_hsla[1]
  lig1 = c1.to_hsla[2]
  lig2 = c2.to_hsla[2]
  
  if (hue1 == hue2) 
    if (sat1 == sat2)
      lig1 <=> lig2
    else
      sat1 <=> sat2
    end
  else
    hue1 <=> hue2
  end

}

# Create the palette image
gc = Magick::Draw.new
gc.stroke_width(1)
gc.affine(1, 0, 0, 1, 0, 0)

max_colors_per_row = 40

start = 0
y = 0
colors.each { |pixel|
  if (start + 1)%max_colors_per_row == 0
    start = 0
    y = y + 1
  end
  
  gc.stroke(pixel.to_color)
  gc.line(start, y, (start+1), y)
  start += 1
}

canvas = Magick::Image.new(max_colors_per_row, (y+1))
gc.draw(canvas)

canvas.write("palette.png")

