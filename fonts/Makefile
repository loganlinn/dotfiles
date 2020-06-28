OUT_DIR ?= out

ifeq ($(UNAME),Linux)
	FONT_DIR ?= ~/.local/share/fonts
endif
ifeq ($(UNAME),Darwin)
	FONT_DIR ?= ~/Library/Fonts
endif

get: urls.txt
	wget --directory-prefix $(OUT_DIR) --input-file $< --timestamping
