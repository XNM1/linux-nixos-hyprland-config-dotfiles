<h3 align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/logos/exports/1544x1544_circle.png" width="100" alt="Logo"/><br/>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
	Catppuccin for <a href="https://github.com/qutebrowser/qutebrowser">qutebrowser</a>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h3>

<p align="center">
	<a href="https://github.com/catppuccin/qutebrowser/stargazers"><img src="https://img.shields.io/github/stars/catppuccin/qutebrowser?colorA=363a4f&colorB=b7bdf8&style=for-the-badge"></a>
	<a href="https://github.com/catppuccin/qutebrowser/issues"><img src="https://img.shields.io/github/issues/catppuccin/qutebrowser?colorA=363a4f&colorB=f5a97f&style=for-the-badge"></a>
	<a href="https://github.com/catppuccin/qutebrowser/contributors"><img src="https://img.shields.io/github/contributors/catppuccin/qutebrowser?colorA=363a4f&colorB=a6da95&style=for-the-badge"></a>
</p>

<p align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/qutebrowser/main/assets/screenshot.png"/>
</p>

## Usage

1. Find out where the qutebrowser stores its `config` directory for your OS.<br/>
   Run `:version`, and take a look at `Paths: config` to find out.

2. Clone this repo into that `config` directory:

```sh
# Linux
$ git clone https://github.com/catppuccin/qutebrowser.git ~/.config/qutebrowser/catppuccin
# macOS
$ git clone https://github.com/catppuccin/qutebrowser.git ~/.qutebrowser/catppuccin
# windows
$ git clone https://github.com/catppuccin/qutebrowser.git $LOCALAPPDATA/qutebrowser/config/catppuccin
```

3. Make sure your `config.py` contains:

```python
import catppuccin

# load your autoconfig, use this if the rest of your config is empty!
config.load_autoconfig()

# set the flavour you'd like to use
# valid options are 'mocha', 'macchiato', 'frappe', and 'latte'
catppuccin.setup(c, 'mocha')
```

4. Done!

## 💝 Thanks to

-   [winston](https://github.com/nekowinston)

&nbsp;

<p align="center">
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" />
</p>

<p align="center">
	Copyright &copy; 2021-present <a href="https://github.com/catppuccin" target="_blank">Catppuccin Org</a>
</p>

<p align="center">
	<a href="https://github.com/catppuccin/catppuccin/blob/main/LICENSE"><img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=d9e0ee&colorA=363a4f&colorB=b7bdf8"/></a>
</p>
