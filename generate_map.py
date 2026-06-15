import sys

width = 100
height = 100
data = []

for y in range(height):
    for x in range(width):
        # 1: empty road, 2: building (collides)
        if x == 0 or x == width - 1 or y == 0 or y == height - 1:
            data.append("2") # border
        elif x % 10 in (0, 1) and y % 10 in (0, 1):
            data.append("2") # building blocks
        else:
            data.append("1") # road/ground

data_str = ", ".join(data)

lua_content = f"""return {{
  version = "1.5",
  luaversion = "5.1",
  tiledversion = "1.7.2",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = {width},
  height = {height},
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 2,
  nextobjectid = 1,
  properties = {{}},
  tilesets = {{
    {{
      name = "kathmandu_tiles",
      firstgid = 1,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 8,
      image = "../assets/tiles/kathmandu_tiles.png",
      imagewidth = 256,
      imageheight = 256,
      objectalignment = "unspecified",
      tileoffset = {{ x = 0, y = 0 }},
      grid = {{ orientation = "orthogonal", width = 32, height = 32 }},
      properties = {{}},
      terrains = {{}},
      tilecount = 64,
      tiles = {{
        {{
          id = 1,
          properties = {{
            ["collides"] = true
          }}
        }}
      }}
    }}
  }},
  layers = {{
    {{
      type = "tilelayer",
      id = 1,
      name = "Buildings",
      x = 0,
      y = 0,
      width = {width},
      height = {height},
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {{}},
      encoding = "lua",
      data = {{
        {data_str}
      }}
    }}
  }}
}}
"""

with open("maps/test_map.lua", "w") as f:
    f.write(lua_content)

print("Map generated!")
