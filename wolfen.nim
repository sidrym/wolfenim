import sdl2, os, times, sdl2/ttf, system

var
  height = cint(480)
  width = cint(640)

type
  input {.pure.} = enum none, left, right, up, down

if init(INIT_VIDEO) == SdlError:
  quit("Couldn't initialise SDL")

var
  window: WindowPtr
  renderer: RendererPtr
  font = openFontRW(rwFromFile(cstring("DejaVuSans.ttf"), "r"), freesrc = 1, 28)

if createWindowAndRenderer(width, height, 0, window, renderer) == SdlError:
  quit("Counldn't create a window or renderer")

var
  pos_x: float = 22
  pos_y: float = 12

  plane_x: float = 0
  plane_y: float = 0.66
  dir_x: float = -1
  dir_y: float = 0

  time: float
  old_time: float

  map =
    [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 4, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 4, 0, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]

while true:
  renderer.clear
  renderer.setDrawColor(0, 0, 0, 0)
  for x in countup(0, width):
    var
      camera_x: float = float(2 * x) / float(width) - 1
      ray_dir_x: float = dir_x + plane_x * camera_x
      ray_dir_y: float = dir_y + plane_y * camera_x

      side_dist_x: float
      side_dist_y: float


      delta_dist_x = abs(1 / ray_dir_x)
      delta_dist_y = abs(1 / ray_dir_y)

      map_x = int(pos_x)
      map_y = int(pos_y)

      hit = false
      step_x = 0
      step_y = 0
      side: int
      perp_wall_dist: float
      line_height = 0
      draw_start = 0
      draw_end = 0
      reoo = renderText(font, "nigga", color(255, 255, 255, 200), color(200, 200, 200, 200))


    if ray_dir_x < 0:
      step_x = -1
      side_dist_x = (pos_x - float(map_x)) * delta_dist_x
    else:
      step_x = 1
      side_dist_x = (float(map_x) + 1 - pos_x) * delta_dist_x
    if ray_dir_y < 0:
      step_y = -1
      side_dist_y = (pos_y - float(map_y)) * delta_dist_y
    else:
      step_y = 1
      side_dist_y = (float(map_y) + 1 - pos_y) * delta_dist_y

    while not hit:
      if (side_dist_x < side_dist_y):
        side_dist_x += delta_dist_x
        map_x += step_x
        side = 0
      else:
        side_dist_y += delta_dist_y
        map_y += step_y
        side = 1
      if (map[map_x][map_y] > 0):
        hit = true

    perp_wall_dist =
      if side == 0: (float(map_x) - pos_x + (1 - step_x) / 2) / ray_dir_x
      else: (float(map_y) - pos_y + (1 - step_y) / 2) / ray_dir_y

    line_height = int(height) div int(perp_wall_dist)

    draw_start = int(-line_height / 2) + int(height / 2)
    if (draw_start < 0):
      draw_start = 0

    draw_end = int(line_height / 2) + int(height / 2)
    if (draw_end >= height):
      draw_end = height - 1


    var
      alpha = if (side == 1): 150
              else: 255
      new_color =
        case map[map_x][map_y]
        of 1: color(255, 0, 0, alpha)     # red
        of 2: color(0, 255, 0, alpha)     # green
        of 3: color(0, 0, 255, alpha)     # blue
        of 4: color(255, 255, 255, alpha) # white
        else: color(255, 255, 0, alpha)   # yellow
    var i = 0
    while (i < height):
      renderer.setDrawColor(250,229,192,255)
      renderer.drawLine(cint(x), cint(i), cint(x), cint(i + 2))
      inc(i, 2)
      renderer.setDrawColor(244,244,223,255)
      renderer.drawLine(cint(x), cint(i), cint(x), cint(i + 2))
      inc(i, 2)
    renderer.setDrawColor new_color
    renderer.drawLine(cint(x), cint(draw_start), cint(x), cint(draw_end))
    renderText(font, "nigga", color(255, 255, 255, 200), color(200, 200, 200, 200))
  renderer.present
#  var event = defaultEvent
#  old_time = time
#  time = cpuTime()
#  var frame_time = (time - oldTime) / 1000.0
#  renderer.print(1.0 / frame_time)
#  renderer.present
#  while pollEvent(event):
#    case event.kind
#    of KeyDown:
#      if (map[int(pos_x + dir_x *)])
