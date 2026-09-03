# Bento Sketch control coverage

The theme targets Godot 4.7.1 and covers the following base UI families.

| Family | Controls and theme types |
| --- | --- |
| Typography | `Label`, `RichTextLabel`, heading/muted/badge variations |
| Actions | `Button`, primary/quiet variations, `LinkButton`, `MenuButton`, `TextureButton` sample |
| Selection | `CheckBox`, `CheckButton`, `RadioButton` variation, `OptionButton` |
| Text and numeric input | `LineEdit`, `TextEdit`, `CodeEdit`, `SpinBox` |
| Ranges and progress | `HSlider`, `VSlider`, `ProgressBar`, `HScrollBar`, `VScrollBar` |
| Collections | `ItemList`, `Tree` including selection, guides, checks, and expansion arrows |
| Navigation and menus | `TabBar`, `TabContainer`, `MenuBar`, `PopupMenu` |
| Containers | `Panel`, `PanelContainer`, `ScrollContainer`, `HSeparator`, `VSeparator` |
| Overlays | Tooltip panel/label, embedded `Window`, `AcceptDialog`, `ConfirmationDialog` |

Interactive controls include coherent normal, hover, pressed or active, keyboard-focus, disabled, selected/checked, and read-only states wherever Godot exposes them. Popup menus also include checkbox, radio, submenu, separator, disabled, and hover styling.

`TextureButton` does not expose theme-item textures through Godot's `Theme` resource, so its showcase uses the original bundled `icons/spark.svg` asset directly.
