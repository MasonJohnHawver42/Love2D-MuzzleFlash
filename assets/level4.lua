return {
  version = "1.5",
  luaversion = "5.1",
  tiledversion = "1.6.0",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 100,
  height = 100,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 5,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "simple16",
      firstgid = 1,
      filename = "simple16.tsx",
      exportfilename = "simple16.lua"
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      id = 1,
      name = "Floor",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["Z"] = 0
      },
      encoding = "lua",
      chunks = {
        {
          x = 0, y = 0, width = 16, height = 16,
          data = {
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 42, 0, 42, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0, 0,
            0, 0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0, 0,
            0, 0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0, 0,
            0, 0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0, 0,
            0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0,
            0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0,
            0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0,
            0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0,
            0, 0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0, 0,
            0, 0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0, 0,
            0, 0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0, 0,
            0, 0, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          }
        }
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      id = 2,
      name = "Walls",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["Z"] = 1
      },
      encoding = "lua",
      chunks = {
        {
          x = 0, y = 0, width = 16, height = 16,
          data = {
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 43, 34, 34, 34, 34, 34, 41, 0, 0, 0, 0, 0,
            0, 43, 34, 34, 34, 0, 0, 0, 0, 0, 34, 34, 34, 41, 0, 0,
            0, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0,
            0, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0,
            43, 34, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 34, 41, 0,
            43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0,
            43, 0, 0, 0, 0, 0, 0, 53, 0, 0, 0, 0, 0, 0, 41, 0,
            43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0,
            43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0,
            51, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 33, 49, 0,
            0, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0,
            0, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0,
            0, 51, 50, 50, 35, 0, 0, 0, 0, 0, 33, 50, 50, 49, 0, 0,
            0, 0, 0, 0, 51, 50, 50, 50, 50, 50, 49, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          }
        }
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      id = 3,
      name = "Foreground",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["Z"] = 5
      },
      encoding = "lua",
      chunks = {
        {
          x = 0, y = 0, width = 16, height = 16,
          data = {
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 34, 34, 34, 34, 34, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          }
        }
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 100,
      height = 100,
      id = 4,
      name = "things",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["Z"] = -1
      },
      encoding = "lua",
      chunks = {
        {
          x = 0, y = 0, width = 16, height = 16,
          data = {
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 36, 0, 36, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 44, 0, 0, 0, 0, 9, 0, 0, 0, 0, 52, 0, 0, 0,
            0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
            0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
            0, 0, 0, 2, 2, 0, 0, 36, 0, 0, 0, 2, 0, 0, 0, 0,
            0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
            0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
            0, 0, 2, 2, 2, 2, 11, 2, 11, 0, 0, 2, 0, 0, 0, 0,
            0, 0, 44, 2, 2, 2, 2, 2, 2, 2, 2, 2, 52, 0, 0, 0,
            0, 0, 2, 2, 0, 0, 11, 0, 11, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 36, 0, 36, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          }
        }
      }
    }
  }
}
