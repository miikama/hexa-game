
# GREENIFY

A small strategy game where you try to convert dry desert into green forests. 

![menu](graphics/example_menu_screen.png)

The game map is a hexa-tile based map. Players build water pumps into the dry desert and expand their territory. The one with the biggest territory wins! 

![game](graphics/example_game_screen.png)

> DISCLAIMER: this is just a hobby game for testing Godot functionality and is totally incomplete

## Development

set up a pre-commit hook for formatting

```
python3 -m pip "install gdtoolkit==3.*"
mv  .git/hooks/pre-commit.sample .git/hooks/pre-commit
vim .git/hooks/pre-commit

# add the following line
gdformat $(find . -name '*.gd')
```
