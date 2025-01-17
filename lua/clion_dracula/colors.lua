-- lua/clion_dracula/colors.lua
---@alias Hex string
---@class RGB
---@field red integer
---@field green integer
---@field blue integer
---@class HSL
---@field hue number
---@field saturation number
---@field luminance number

local M = {}

---@param hex Hex
---@return RGB
M.hex_to_rgb = function(hex)
  return {
    red   = tonumber(string.sub(hex, 2, 3), 16),
    green = tonumber(string.sub(hex, 4, 5), 16),
    blue  = tonumber(string.sub(hex, 6, 7), 16),
  }
end

---@param rgb RGB
---@return Hex
M.rgb_to_hex = function(rgb)
  return string.format("#%.2x%.2x%.2x", rgb.red, rgb.green, rgb.blue)
end

---@param rgb RGB
---@return HSL
M.rgb_to_hsl = function(rgb)
  local m = M._min_max_rgb(rgb)
  local min = m.min.val
  local max = m.max.val
  local max_color = m.max.color

  local range = max - min
  local luminance = min + max

  local saturation
  if min == max then
    saturation = 0
  elseif luminance <= 255 then
    saturation = range / luminance
  else
    saturation = range / (510 - luminance)
  end

  local hue
  if min == max then
    hue = 0
  elseif max_color == "red" then
    hue = (rgb.green - rgb.blue) / range
  elseif max_color == "green" then
    hue = (2 * range + rgb.blue - rgb.red) / range
  else
    hue = (4 * range + rgb.red - rgb.green) / range
  end

  if hue < 0 then
    hue = hue + 6
  end

  return {
    hue        = hue * 60,
    saturation = saturation,
    luminance  = luminance / 510,
  }
end

M._min_max_rgb = function(rgb)
  local min = { color = "", val = 256 }
  local max = { color = "", val = -1 }
  for color, value in pairs(rgb) do
    if value < min.val then
      min.color = color
      min.val   = value
    end
    if value > max.val then
      max.color = color
      max.val   = value
    end
  end
  return { min = min, max = max }
end

---@param hsl HSL
---@return RGB
M.hsl_to_rgb = function(hsl)
  local abs = math.abs
  local floor = math.floor
  local C = (1 - abs(2 * hsl.luminance - 1)) * hsl.saturation
  local H = hsl.hue / 60
  local X = C * (1 - abs(H % 2 - 1))
  local m = hsl.luminance - C / 2
  H = floor(H)
  return M._hsl_to_rgb_piecewise(H, C, X, m)
end

M._hsl_to_rgb_piecewise = function(H, C, X, m)
  local rgb_switch = {
    M._h0, M._h1, M._h2, M._h3, M._h4, M._h5
  }
  return rgb_switch[H + 1](C * 255, X * 255, m * 255)
end

M._h0 = function(C, X, m) return { red = C + m, green = X + m, blue = m } end
M._h1 = function(C, X, m) return { red = X + m, green = C + m, blue = m } end
M._h2 = function(C, X, m) return { red = m, green = C + m, blue = X + m } end
M._h3 = function(C, X, m) return { red = m, green = X + m, blue = C + m } end
M._h4 = function(C, X, m) return { red = X + m, green = m, blue = C + m } end
M._h5 = function(C, X, m) return { red = C + m, green = m, blue = X + m } end

---@param hex Hex
---@return HSL
M.hex_to_hsl = function(hex)
  return M.rgb_to_hsl(M.hex_to_rgb(hex))
end

---@param hsl HSL
---@return Hex
M.hsl_to_hex = function(hsl)
  return M.rgb_to_hex(M.hsl_to_rgb(hsl))
end

---@param val number
---@param max number
---@param t number [-1, 1]
---@return number
M._lerp = function(val, max, t)
  if t >= 0 then
    return val + (max - val) * (t > 1 and 1 or t)
  else
    return val + val * (t < -1 and -1 or t)
  end
end

M._normalize_scalar = function(scalar, max)
  if scalar >= 0 then
    return (scalar > max) and 1 or scalar / max
  else
    return (scalar < -max) and -1 or scalar / max
  end
end

---@param hsl HSL
---@param rot_t number [0, 359]
---@param sat_t number [-100, 100]
---@param lum_t number [-100, 100]
---@return HSL
M.hsl_trans = function(hsl, rot_t, sat_t, lum_t)
  sat_t = M._normalize_scalar(sat_t, 100)
  lum_t = M._normalize_scalar(lum_t, 100)

  return {
    hue        = (hsl.hue + rot_t) % 360,
    saturation = M._lerp(hsl.saturation, 1, sat_t),
    luminance  = M._lerp(hsl.luminance,  1, lum_t),
  }
end

---@param hex Hex
---@param rot_t number
---@param sat_t number
---@param lum_t number
---@return Hex
M.hex_trans_with_hsl = function(hex, rot_t, sat_t, lum_t)
  local hsl = M.hex_to_hsl(hex)
  local new_hsl = M.hsl_trans(hsl, rot_t, sat_t, lum_t)
  return M.hsl_to_hex(new_hsl)
end

---@param hex1 Hex
---@param hex2 Hex
---@param weight number [0,1]
---@return Hex
M.hex_blend_with_rgb = function(hex1, hex2, weight)
  local rgb1 = M.hex_to_rgb(hex1)
  local rgb2 = M.hex_to_rgb(hex2)

  local blended_rgb = {
    red   = math.floor((1 - weight) * rgb1.red   + weight * rgb2.red),
    green = math.floor((1 - weight) * rgb1.green + weight * rgb2.green),
    blue  = math.floor((1 - weight) * rgb1.blue  + weight * rgb2.blue),
  }

  return M.rgb_to_hex(blended_rgb)
end

return M

