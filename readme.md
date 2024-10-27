# NumpadMouse: Numpad-Based Mouse Emulator
This AutoHotKey script emulates mouse movement, clicks and scrolling using the numpad keys.

This script is based on [a previous work by deguix and mslonik](https://github.com/mslonik/Autohotkey-scripts/tree/master/NumpadMouse).

## Main functions
The mouse emulation is achieved by using the following keys:
- WheelLeft and WheelRight
- Combo arrow keys: for example, by pressing either `NumpadHome` or `up + left`, the cursor will move in the up-left direction.
- Mouse Leap: move cursor to the center of the windows being focused. (Hope it makes the life easier for people like me who use multiple monitors.)
- Lattice move: move cursor between grid points. The grid size is customizable.

This script is an example of using AutoHotkey to remap numpad keys to emulate mouse functions. Key features include acceleration (increasing mouse movement speed when holding a key) and rotation (changing the direction of movement). Below is a list of keys and their functions:

1. Configuration

| Keys                  | Description                                                    |
|-----------------------|----------------------------------------------------------------|
| ScrollLock (toggle on)| Activates numpad mouse mode.                                   |
| NumLock (toggled off) | Activates mouse movement mode.                                 |
| NumLock (toggled on)  | Activates mouse speed adjustment mode.                         |
| Numpad7/Numpad1       | Increase/decrease acceleration per button press.               |
| Numpad8/Numpad2       | Increase/decrease initial speed per button press.              |
| Numpad9/Numpad3       | Increase/decrease maximum speed per button press.              |
| !Numpad7/^Numpad1     | Increase/decrease wheel acceleration per button press*.        |
| !Numpad8/^Numpad2     | Increase/decrease wheel initial speed per button press*.       |
| !Numpad9/^Numpad3     | Increase/decrease wheel maximum speed per button press*.       |
| Numpad4/Numpad6       | Increase/decrease rotation angle to right in degrees. (i.e. 180° = inversed controls). |

2. Movement
In mouse movement mode (NumLock off), the following keys are used to move the cursor:
```
NumpadHome Up   NumpadEnd     =>    Up-Left   Up     Up-Right
Left       .    Right         =>    Left      LClick Right
NumpadPgUp Down NumpadPgDn    =>    Down-Left Down   Down-Right
```

3. Movement on lattice
In mouse movement mode (NumLock off), with the modifier key `!` (Alt) pressed, the mouse will move to the nearest grid point. The grid size is customizable (by editing `NumpadMouse.ini`).


4. Clicks
Keys for mouse wheel and buttons. Specially, `#` (Shift) can be used to move the mouse wheel horizontally.

| Keys                  | Description                                                    |
|-----------------------|----------------------------------------------------------------|
| Numpad0               | Left mouse button click.                                       |
| Numpad5               | Middle mouse button click.                                     |
| NumpadDot             | Right mouse button click.                                      |
| NumpadDiv/NumpadMult  | X1/X2 mouse button click. (Win 2k+)                            |
| NumpadSub/NumpadAdd   | Moves up/down the mouse wheel.                                 |
| #NumpadSub/#NumpadAdd | Moves left/right the mouse wheel.                              |



## Q & A
### Why does it make no effect after editing the content of `.ini` file?
Make sure you found the right `.ini` file. By default it's created in the `A_ScriptDir`, along side with `NumpadMouse.ahk`, but it might also not be the case, for example, when invoking `NumpadMouse.ahk` from another AHK script.
To check them by yourself, use the MsgBox line in following part of the script:
``` ahk
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory: the directory containing the script.

; MsgBox, The current working directory is: %A_WorkingDir%, while the script directory is: %A_ScriptDir%.
```

### How to use the emulation with ZMK?
Here is part of a `.keymap` file that works with this script. It controls mouse in the `nav_layer`

``` cpp
//  corne.keymap
    keymap {

        default_layer {
            // -----------------------------------------------------------------------------------------
            // |  TAB |  Q  |  W  |  E  |  R  |  T  |   |  Y  |  U   |  I  |  O  |  P  | BKSP |
            // | CTRL |  A  |  S  |  D  |  F  |  G  |   |  H  |  J   |  K  |  L  |  ;  |  '   |
            // | SHFT |  Z  |  X  |  C  |  V  |  B  |   |  N  |  M   |  ,  |  .  |  /  | ESC  |
            //                    | GUI | LALT | Mouse & SPC |   | ENT | SPC  | RCTRL |

            bindings = <
&kp TAB     &kp Q            &kp W     &kp E            &kp R            &kp T             &kp Y             &kp U        &kp I      &kp O       &kp P         &kp BKSP
&kp LCTRL   &kp A            &kp S     &kp D            &kp F            &kp G             &kp H             &kp J        &kp K      &kp L       &kp SEMI    &kp SQT
&kp LSHIFT  &kp Z            &kp X     &kp C            &kp V            &kp B             &kp N             &kp M        &kp COMMA  &kp DOT     &kp SLASH     &kp ESC
                                  &kp LGUI &lalt  &lt NAV SPACE      &kp ENTER  &lt NAV SPACE  &kp RCTRL
            >;
        };

        nav_layer {
    // -----------------------------------------------------------------------------------------
    // |  |             |        | m_up    |         |  m_leap   |        |        |              | m_up        | m_tog_conf |              |  | 
    // |  | m_wheelDown | m_left | m_down  | m_right | m_wheelUp |        |        | m_left       | m_down      | m_right    |              |  |
    // |  | m_lClick    |        |         | m_menu  | m_rClick  |        | m_leap |  m_wheelLeft | m_wheelDown | m_wheelUp  | m_wheelRight |  |
            bindings = <
&trans  &kp KP_DIVIDE    &trans     &kp KP_N8    &trans       &kp KP_MULTIPLY  &trans           &trans               &kp KP_N8    &kp KP_NUMLOCK   &trans           &trans
&trans   &kp KP_PLUS      &kp KP_N4  &kp KP_N2    &kp KP_N6    &kp KP_MINUS     &trans           &kp KP_N4            &kp KP_N2    &kp KP_N6        &trans           &trans
&trans   &kp KP_NUMBER_0  &trans     &trans       &kp K_CMENU  &kp KP_DOT       &kp KP_MULTIPLY  &kp LS(KP_SUBTRACT)  &kp KP_PLUS  &kp KP_SUBTRACT  &kp LS(KP_PLUS)  &tog NAV
                                     &mt LALT AT  &trans     &trans           &kp KP_NUMBER_0  &kp KP_DOT         &trans
            >;

            label = "nav";
        };
    };

```
