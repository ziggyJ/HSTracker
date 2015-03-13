# extra NSArray methods
class NSArray

  # [160, 210, 242].nscolor
  def nscolor(alpha=1.0)
    red = self[0] / 255.0
    green = self[1] / 255.0
    blue = self[2] / 255.0
    if self[3]
      alpha = self[3]
    end
    NSColor.colorWithRed(red, green:green, blue:blue, alpha:alpha.to_f)
  end

end
