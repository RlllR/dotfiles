-------------------------------------------------------------------------------
-- Import modules
-------------------------------------------------------------------------------
import XMonad
import XMonad.Util.Run

-- actions
import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.PerWorkspaceKeys
import qualified XMonad.Actions.FlexibleResize as Flex -- flexible resize
import XMonad.Actions.FloatKeys
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WindowGo

-- hooks
import XMonad.Operations
import XMonad.Hooks.DynamicLog   -- for xmobar
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops -- fix chromium fullscreen
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName

-- layout
import XMonad.Layout
import XMonad.Layout.DragPane
import XMonad.Layout.Gaps
import XMonad.Layout.NoBorders (smartBorders, noBorders)
import XMonad.Layout.PerWorkspace (onWorkspace, onWorkspaces)
import XMonad.Layout.Simplest
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing       -- this makes smart space around windows
import XMonad.Layout.ToggleLayouts -- Full window at any time
import XMonad.Layout.ResizableTile -- Resizable Horizontal border
import XMonad.Layout.Grid
import XMonad.Layout.TwoPane
import XMonad.Layout.OneBig

-- misc
import System.Exit
import System.IO                      -- for xmobar
import Data.Ratio ((%))
import qualified XMonad.StackSet as W -- myManageHookShift
import qualified Data.Map as M

-- Prompt Util
import XMonad.Prompt
import XMonad.Prompt.Window           -- pops up a prompt with window names
import XMonad.Util.EZConfig           -- removeKeys, additionalKeys
import XMonad.Util.Run
import XMonad.Util.Run(spawnPipe)     -- spawnPipe, hPutStrLn
import XMonad.Util.SpawnOnce

import Control.Monad (liftM2)         -- myManageHookShift
import Graphics.X11.ExtraTypes.XF86

-------------------------------------------------------------------------------
-- Local variables
-------------------------------------------------------------------------------
myWorkspaces = ["1", "2", "3", "4", "5"]
modm = mod1Mask -- modkey (alt) mod4mask = Window

-- Color Setting
colorBule     = "#868bae"
colorGreen    = "#00d700"
colorRed      = "#ff005f"
colorGray     = "#666666"
colorWhite    = "#bdbdbd"
colorNormalbg = "#1c1c1c"
colorfg       = "#a8b6b8"

-- Border Width
borderwidth = 2

-- Border Color
mynormalBorderColor = "#262626"
myfocusedBorderColor = "#ededed"

-- Float window control width
moveWD = borderwidth
resizeWD = 2*borderwidth

-- gapwidth
gapwidth = 4
gwU = 11
gwD = 11
gwL = 56
gwR = 55

-- terminal
myTerminal = "alacritty"

-------------------------------------------------------------------------------
-- main
-------------------------------------------------------------------------------
main :: IO ()

main = do
    wsbar <- spawnPipe myWsBar
    xmonad $ ewmh defaultConfig
        { borderWidth        = borderwidth
        , terminal           = myTerminal
        , focusFollowsMouse  = True
        , normalBorderColor  = mynormalBorderColor
        , focusedBorderColor = myfocusedBorderColor
        , startupHook        = myStartupHook
        , manageHook         = myManageHookShift <+>
                               myManageHookFloat <+>
                               manageDocks
        , layoutHook         = avoidStruts $ ( toggleLayouts (noBorders Full)
                                             $ onWorkspace "3" simplestFloat
                                             $ onWorkspace "5" (
                                                 spacing 14
                                                 $ gaps [(U, 2),(D,2),(L,5),(R,5)]
                                                 $ ResizableTall 0 (1/42) (1/2) [])
                                             $ myLayout
                                             )
        -- xmobar setting
        , logHook          = myLogHook wsbar
                                >> updatePointer (0.5, 0.5) (0, 0)
        , handleEventHook  = fullscreenEventHook
        , workspaces       = myWorkspaces
        , modMask          = modm
        , mouseBindings    = newMouse
        }

        -----------------------------------------------------------------------
        -- Define keys to remove
        -----------------------------------------------------------------------
        `removeKeysP`
        [
        -- Unused gmrun binding
        "M-S-p",
        -- Unused close window binding
        "M-S-c",
        "M-S-<Return>"
        ]

        -----------------------------------------------------------------------
        -- Keymap: window operations
        -----------------------------------------------------------------------
        `additionalKeysP`
        [
        -- Shrink / Expand the focused window
          ("M-,"    , sendMessage Shrink)
        , ("M-."    , sendMessage Expand)
        , ("M-z"    , sendMessage MirrorShrink)
        , ("M-a"    , sendMessage MirrorExpand)
        -- Close the focused window
        , ("M-c"    , kill1)
        -- Toggle layout (Fullscreen mode)
        , ("M-f"    , sendMessage ToggleLayout)
        , ("M-S-f"  , withFocused (keysMoveWindow (-borderwidth,-borderwidth)))
        -- Move the focused window
        , ("M-C-<R>", withFocused (keysMoveWindow (moveWD, 0)))
        , ("M-C-<L>", withFocused (keysMoveWindow (-moveWD, 0)))
        , ("M-C-<U>", withFocused (keysMoveWindow (0, -moveWD)))
        , ("M-C-<D>", withFocused (keysMoveWindow (0, moveWD)))
        -- Resize the focused window
        , ("M-s"    , withFocused (keysResizeWindow (-resizeWD, resizeWD) (0.5, 0.5)))
        , ("M-i"    , withFocused (keysResizeWindow (resizeWD, resizeWD) (0.5, 0.5)))
        -- Increase / Decrease the number of master pane
        , ("M-S-;"  , sendMessage $ IncMasterN 1)
        , ("M--"    , sendMessage $ IncMasterN (-1))
        -- Go to the next / Previous workspace
        , ("M-<R>"  , nextWS)
        , ("M-<L>"  , prevWS)
        , ("M-l"    , nextWS)
        , ("M-h"    , prevWS)
        -- Shift the focused window to the next / previous workspace
        , ("M-S-<R>", shiftToNext)
        , ("M-S-<L>", shiftToPrev)
        , ("M-S-l"  , shiftToNext)
        , ("M-S-h"  , shiftToNext)
        -- CopyWindow
        , ("M-v"    , windows copyToAll)
        , ("M-S-v"  , killAllOtherCopies)
        -- Move the focus down / up
        , ("M-<D>"  , windows W.focusDown)
        , ("M-<U>"  , windows W.focusUp)
        , ("M-j"    , windows W.focusDown)
        , ("M-k"    , windows W.focusUp)
        -- Swap the focused window down / up
        , ("M-S-j"  , windows W.swapDown)
        , ("M-S-k"  , windows W.swapUp)
        -- Shift the focused window to the master window
        , ("M-S-m"  , windows W.shiftMaster)
        -- Search a window and focus into the window
        , ("M-g"    , windowPromptGoto myXPConfig)
        -- Search a window and bring to the current workspace
        , ("M-b"    , windowPromptBring myXPConfig)
        -- Move the focus to next screen (multi screen)
        , ("M-<Tab>", nextScreen)
        ]

        -----------------------------------------------------------------------
        -- Keymap: Manage workspace
        -----------------------------------------------------------------------
        -- mod-[1..9]         Switch to workspace N
        -- mod-shift-[1..9]   Move window to workspace N
        -- mod-control-[1..9] Copy window to workspace N

        `additionalKeys`
        [ ((m .|. modm, k) , windows $ f i)
          | (i, k) <- zip myWorkspaces [xK_1 ..]
          , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, controlMask)]
        ]

        -----------------------------------------------------------------------
        -- Keymap: custom commands
        -----------------------------------------------------------------------

        `additionalKeysP`
        [
        -- Lock screen
          ("M1-C-l", spawn "xscreensaver-command -lock")
        -- Toggle compton (compsite manager)
        , ("M1-C-t", spawn "bash toggle_compton.sh")
        -- Launch terminal
        , ("M-<Return>", spawn myTerminal)
        -- Insert a transparent panel
        ]

-------------------------------------------------------------------------------
-- myLayout: Handle Window behaveior
-------------------------------------------------------------------------------

myLayout = spacing gapwidth $ gaps [(U, gwU),(D, gwD),(D,gwD),(L,gwL),(R,gwR)]
            $ (ResizableTall 1 (1/201) (116/201) [])
              ||| (TwoPane (1/201) (116/201))
              ||| Simplest

-------------------------------------------------------------------------------
-- myStartupHook : Start up applications
-------------------------------------------------------------------------------

myStartupHook = do
        spawnOnce "gnome-settings-daemon"
        spawnOnce "nm-applet"
        spawnOnce "xscreensaver -no-splash"

-------------------------------------------------------------------------------
-- myManageHookShift: some window must created there
-------------------------------------------------------------------------------

myManageHookShift = composeAll
        -- if you want to know className, type "$ xprop|grep Class" on shell
        [ className =? "Gimp"         --> mydoShift "3"
        , stringProperty "WM_NAME" =? "Figure 1" --> doShift "5"
        ]
        where mydoShift = doF . liftM2 (.) W.greedyView W.shift

-------------------------------------------------------------------------------
-- myManageHookFloat: new window will created in Float mode
-------------------------------------------------------------------------------
myManageHookFloat = composeAll
    [ className =? "Gimp"      --> doFloat
    --, className =? "Tk"        --> doFloat
    ]

-------------------------------------------------------------------------------
-- myLogHook: loghook settings
-------------------------------------------------------------------------------
myLogHook h = dynamicLogWithPP $ wsPP { ppOutput = hPutStrLn h }

-------------------------------------------------------------------------------
-- myWsVar: xmobar setting
-------------------------------------------------------------------------------

myWsBar = "xmobar $HOME/.xmonad/xmobarrc"

wsPP = xmobarPP { ppOrder           = \(ws:l:t:_)  -> [ws,t]
                , ppCurrent         = xmobarColor colorRed     colorNormalbg . \s -> "●"
                , ppUrgent          = xmobarColor colorGray    colorNormalbg . \s -> "●"
                , ppVisible         = xmobarColor colorRed     colorNormalbg . \s -> "◉"
                , ppHidden          = xmobarColor colorGray    colorNormalbg . \s -> "●"
                , ppHiddenNoWindows = xmobarColor colorGray    colorNormalbg . \s -> "○"
                , ppTitle           = xmobarColor colorGray    colorNormalbg
                , ppOutput          = putStrLn
                , ppWsSep           = " "
                , ppSep             = "  "
                }

-------------------------------------------------------------------------------
-- myXPConfig: XPConfig
-------------------------------------------------------------------------------

myXPConfig = defaultXPConfig
                { font              = "xft:Migu 1M:size=20:antialias=true"
                , fgColor           = colorfg
                , bgColor           = colorNormalbg
                , borderColor       = colorNormalbg
                , height            = 35
                , promptBorderWidth = 0
                , autoComplete      = Just 100000
                , bgHLight          = colorNormalbg
                , fgHLight          = colorRed
                , position          = Bottom
                }

-------------------------------------------------------------------------------
-- newMouse: Right click is used for resizing window
-------------------------------------------------------------------------------

myMouse x = [ ((modm, button3), (\w -> focus w >> Flex.mouseResizeWindow w)) ]
newMouse x = M.union (mouseBindings defaultConfig x) (M.fromList (myMouse x))


-- vim: ft=haskell
