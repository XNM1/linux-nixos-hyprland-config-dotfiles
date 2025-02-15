import catppuccin

# load your autoconfig, use this if the rest of your config is empty!
config.load_autoconfig()

# set the flavour you'd like to use
# valid options are 'mocha', 'macchiato', 'frappe', and 'latte'
catppuccin.setup(c, 'macchiato')

config.bind('<Up>', 'scroll up')
config.bind('<Down>', 'scroll down')
config.bind('<Left>', 'scroll left')
config.bind('<Right>', 'scroll right')

config.bind('<Shift+Left>',  'back')
config.bind('<Shift+Right>', 'forward')
config.bind('<Shift+Down>',  'tab-next')
config.bind('<Shift+Up>',    'tab-prev')
