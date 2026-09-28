
swayimg.gallery.thumb_size = 128 
swayimg.gallery.pstore = true --store thumbnails in ~/.cache/swayimg
swayimg.viewer.preload = 3
swayimg.viewer.history = 4 --how many just viewed images to keep in memory
swayimg.gallery.on_key("h", function() swayimg.gallery.select("left") end)
swayimg.gallery.on_key("l", function() swayimg.gallery.select("right") end)
swayimg.gallery.on_key("k", function() swayimg.gallery.select("up") end)
swayimg.gallery.on_key("j", function() swayimg.gallery.select("down") end)
swayimg.gallery.on_key("q", function() swayimg.exit(0) end)
swayimg.viewer.on_key("f", function() swayimg.viewer.frame = 0 end)
swayimg.viewer.on_key("d", function() swayimg.viewer.frame = swayimg.viewer.frame + 1 end)
swayimg.viewer.on_key("a", function() swayimg.viewer.frame = swayimg.viewer.frame - 1 end)
swayimg.gallery.on_key("g", function() swayimg.gallery.select("first") end)
swayimg.gallery.on_key("Shift+g", function() swayimg.gallery.select("last") end)
swayimg.viewer.on_key("n", function() swayimg.viewer.open("next") end)
swayimg.viewer.on_key("p", function() swayimg.viewer.open("prev") end)
swayimg.viewer.on_key("q", function() swayimg.mode = "gallery" end)

