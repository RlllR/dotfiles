----------------------------------------------------------------------------}}}
-- Import modules                                                           {{{
-------------------------------------------------------------------------------
-- Base
import System.Directory
import System.Exit (exitWith, ExitCode(..), exitSuccess)
import System.IO (hPutStrLn)
import XMonad
import XMonad.Config
import XMonad.Config.Desktop
import qualified XMonad.StackSet as W

-- Util
import XMonad.Util.Cursor (setDefaultCursor)
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

-- Actions
-- import XMonad.Actions.DynamicWorkSpaces (addWorkspacePrompt, removeEmptyWorkspace)
-- import XMonad.Actions.Minimize (minimizeWindow)
-- import qualified XMonad.Actions.ConstrainedResize as Sqr
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.DynamicProjects
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S
import qualified XMonad.Actions.TreeSelect as TS

-- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (isJust)
import Data.Monoid
import Data.Tree
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

-- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Prompt
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import Control.Arrow (first)

-- Text
import Text.Printf

----------------------------------------------------------------------------}}}
-- Main                                                                     {{{
-------------------------------------------------------------------------------

main :: IO ()
main = do
    home <- getHomeDirectory
    xmproc <- spawnPipe "xmobar -x 0 $HOME/.xmonad/xmobarrc"
    xmonad $ ewmh def
      {
        normalBorderColor  = myNormalBorderColor
      , focusedBorderColor = myFocusedBorderColor
      , borderWidth        = myBorderWidth
      , terminal           = myTerminal
      , workspaces         = myWorkspaces
      , modMask            = myModMask
      , focusFollowsMouse  = myFocusFollowsMouse
      , startupHook        = myStartupHook
      , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
      , manageHook         = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
      , handleEventHook    = serverModeEventHookCmd
                             <+> serverModeEventHook
                             <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                             <+> docksEventHook
      -- , mouseBindings      = myMouseBindings
      , logHook            = workspaceHistoryHook <+> myLogHook <+> dynamicLogWithPP xmobarPP
                              { ppOutput = \x -> hPutStrLn xmproc x
                              , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]" -- Current workspace in xmobar
                              , ppVisible = xmobarColor "#98be65" ""                -- Visible but not current workspace
                              , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""   -- Hidden workdspaces in xmobar
                              , ppHiddenNoWindows = xmobarColor "#c792ea" ""
                              , ppUrgent = xmobarColor "#cc3544" "" . wrap "!" "!"  -- Urgent workspace
                              , ppTitle = xmobarColor "#b3afc2" "" . shorten 60
                              , ppSep = "<fc=#666666> <fn=2>|</fn> </fc>"
                              , ppExtras = [windowCount]
                              , ppOrder = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                              }
      -- , clickJustFocuses   = myClickJustFocuses
      -- , clientMask         = myClientMask
      -- , handleExtraArgs    = myHandleExtraArgs
      } `additionalKeysP` myKeys home

----------------------------------------------------------------------------}}}
-- Local variables                                                          {{{
-------------------------------------------------------------------------------
myFont :: String
myFont = "xft:SouceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myModMask, altMask :: KeyMask
myModMask = mod4Mask -- super/windows Key
altMask = mod1Mask -- super/windows Key
-- ctlMask = controlMask -- Control Key
-- shftMask = shiftMask --Shift Key

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

-- Color
base03  = "#022b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#839496"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green   = "#859900"

-- Sizes
gap    = 10
topbar = 10
border = 0
prompt = 20
status = 20

active       = blue
activeWarn   = red
inactive     = base02
focusColor   = blue
unfocusColor = base02

-- Focus
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Applications
myTerminal :: String
myTerminal = "alacritty "

myBrowser :: String
myBrowser = "firefox "

myLauncher :: String
myLauncher = "rofi -matching fuzzy -modi combi -show combi -combi-modi run,drun"

-- Boarder
myBorderWidth :: Dimension
myBorderWidth = 0          -- Sets Border width for windows

myNormalBorderColor ::String
myNormalBorderColor = "#00000"

myFocusedBorderColor :: String
myFocusedBorderColor = active

----------------------------------------------------------------------------}}}
-- Projects                                                                 {{{
-------------------------------------------------------------------------------
projects :: [Project]
projects =
  [ Project { projectName = "term"
            , projectDirectory = "~/Documents/"
            , projectStartHook = Just $ do spawn "tilix -e tmux"
                                           spawn myTerminal
            }
  , Project { projectName = "system"
            , projectDirectory = "~/Documents/"
            , projectStartHook = Just $ do spawn "tilis -e ncmpcpp"
                                           spawn "tilis -e ncmpcpp"
                                           spawn "tilis -e htop"
            }
  ]

----------------------------------------------------------------------------}}}
-- KeyBindings                                                              {{{
-------------------------------------------------------------------------------
quitXmonad :: X ()
quitXmonad = io (exitWith ExitSuccess)

rebuildXmonad :: X ()
rebuildXmonad = do
    spawn "xmonad --recompile && xmonad --restart"

restartXmonad :: X ()
restartXmonad = do
    spawn "xmonad --restart"

-- myKeys :: [(String, X ())]
myKeys :: String -> [([Char], X ())]
myKeys home =
  -- M  = Super
  -- C  = Ctrl
  -- S  = Shift
  -- M1 = Alt
  -- Xmonad
  [ ("M-C-r", rebuildXmonad)  -- Recompile && Restart xmonad
  , ("M-S-r", restartXmonad)  -- Restart xmonad
  , ("M-S-q", quitXmonad)     -- Quits xmonad

  -- Workspaces
  , ("M-.", nextScreen)  -- Switch focus to next monitor
  , ("M-,", prevScreen)  -- Switch focus to prev monitor
  , ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)      -- Shifts focused window to next workspace
  , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP) -- Shifts focused window to prev workspace

  -- Windows
  , ("M-S-c", kill1)                -- Kill the currently focused client
  , ("M-S-a", killAll)              -- Kill all the windows on current workspace

  -- Floating windows
  , ("M-f", sendMessage (T.Toggle "floats"))
  , ("M-t", withFocused $ windows . W.sink) -- Push floating window back to tile
  , ("M-S-t", sinkAll)                      -- Push All floating window back to tile

  -- Windows navigation
  , ("M-m", windows W.focusMaster)
  , ("M-j", windows W.focusDown)
  , ("M-k", windows W.focusUp)
  , ("M-S-m", windows W.swapMaster)
  , ("M-S-j", windows W.swapDown)
  , ("M-S-k", windows W.swapUp)
  , ("M-<Backspace>", promote)
  , ("M-S-<Tab>", rotSlavesDown)
  , ("M-C-<Tab>", rotAllDown)

  -- Layouts
  , ("M-<Tab>", sendMessage NextLayout)     -- Switch to next layout
  -- , ("M-C-M1-<Up>", sendMessage Arrange)
  -- , ("M-C-Ml-<Down>", sendMessage DeArrange)
  , ("M-C-M1-k", sendMessage Arrange)
  , ("M-C-Ml-j", sendMessage DeArrange)
  , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles norborder/full
  , ("M-S-<Space>", sendMessage ToggleStruts)    -- Toggles struts
  , ("M-S-n", sendMessage $ MT.Toggle NOBORDERS) -- Toggles noborder

  -- Run Prompt
  , ("M-p", shellPrompt dtXPConfig)

  -- GridSelect (CTR-g)
  , ("C-g g", spawnSelected' myAppGrid)
  , ("C-g t", goToSelected $ mygridConfig myColorizer)

  , ("M-S-g", goToSelected $ mygridConfig myColorizer)
  , ("M-S-t", goToSelected $ mygridConfig myColorizer)
  , ("M-S-b", bringSelected $ mygridConfig myColorizer)

  -- Tree Select
  , ("C-t t", treeselectAction tsDefaultConfig)

  -- Scratchpads (Super + Ctrl + Enter)
  , ("M-C-<Return>", namedScratchpadAction myScratchPads "terminal")

  -- Open Terminal (Supre+ Enter)
  , ("M-<Return>", spawn myTerminal)
  ]
  ++ [("M-s " ++ k, S.promptSearch dtXPConfig' f) | (k, f) <- searchList]
  ++ [("M-S-s " ++ k, S.selectSearch f) | (k, f) <- searchList]
    where nonNSP         = WSIs (return (\ws -> W.tag ws /= "nsp"))
          nonEmptyNonNSP = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))

----------------------------------------------------------------------------}}}
-- Startup                                                                  {{{
-------------------------------------------------------------------------------
myStartupHook :: X ()
myStartupHook = do
    spawnOnce "lxsession &" -- LXDE
    spawnOnce "nitrogen --restore &" -- wallpaper
    spawnOnce "picom --experimental-backends &" -- composite manager picom
    -- spawnOnce "compton --config /path/to/compton.conf &" -- composite manager compton
    -- spawnOnce "polybar --config /path/to/compton.conf &" -- polybar
    -- spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34  --height 22 &" -- system tray
    -- spawnOnce "nm-applet &" -- network-manager
    -- spawnOnce "valumeicon &" -- network-manager
    -- spawnOnce "$(which emacs) --deamon &" -- emacs daemon for the emacsclient
    setWMName "LG3D"


----------------------------------------------------------------------------}}}
-- Grid Select                                                              {{{
-------------------------------------------------------------------------------
myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                   (0x31,0x2e,0x39) -- lowest inactive bg
                   (0x31,0x2e,0x39) -- highest inactive bg
                   (0x61,0x57,0x72) -- active bg
                   (0xc0,0xa7,0x9a) -- inactive fg
                   (0xff,0xff,0xff) -- active fg

-- gridSelect menu layout
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 30
    , gs_cellwidth    = 200
    , gs_cellpadding  = 8
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 30
                   , gs_cellwidth    = 200
                   , gs_cellpadding  = 8
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

myAppGrid = [ ("Emacs", "emacsclient -c -a emacs")
            , ("Firefox", "firefox")
            ]
----------------------------------------------------------------------------}}}
-- TreeSelect                                                               {{{
-------------------------------------------------------------------------------
treeselectAction :: TS.TSConfig (X ()) -> X ()
treeselectAction a = TS.treeselectAction a
  [ Node (TS.TSNode "+ Power" "" (return ())) []
  , Node (TS.TSNode "+ Accessories" "accessory applications" (return ()))
    [ Node (TS.TSNode "Picom Toggle on/off" "Compositor for window manager" (spawn "killall picom; picom --experimental-backend")) []
    , Node (TS.TSNode "Virtualbox" "Oracle's virtualization program" (spawn "virtualbox")) []
    ]
  , Node (TS.TSNode "+ System" "system tools and utilities" (return ()))
    [ Node (TS.TSNode "Alacirtty" "GPU accelerated terminal" (spawn "alacritty")) []
    , Node (TS.TSNode "Htop" "Terminal process viewer" (spawn (myTerminal ++ " -e htop"))) []
    ]
  , Node (TS.TSNode "------------------------" "" (spawn "xdotool key Escape")) []
  , Node (TS.TSNode "+ Bookmarks" "a list of web bookmarks" (return ()))
      [ Node (TS.TSNode "My Start Page" "Custom start page for browser" (spawn (myBrowser ++ "file://$HOME/.surf/html/homepage.html"))) []
      , Node (TS.TSNode "+ Linux" "a list of web bookmarks" (return ()))
          [ Node (TS.TSNode "+ Arch Linux" "btw, i use arch!" (return ()))
              [ Node (TS.TSNode "Arch Linux" "Arch Linux homepage" (spawn (myBrowser ++ "https://www.archlinux.org/"))) []
              , Node (TS.TSNode "Arch Wiki" "The best Linux wiki" (spawn (myBrowser ++ "https://wiki.archlinux.org/"))) []
              , Node (TS.TSNode "AUR" "Arch User Repository" (spawn (myBrowser ++ "https://aur.archlinux.org/"))) []
              , Node (TS.TSNode "Arch Forums" "Arch Linux web forum" (spawn (myBrowser ++ "https://bbs.archlinux.org/"))) []
              ]
          , Node (TS.TSNode "+ Linux News" "linux news and blogs" (return ()))
              [ Node (TS.TSNode "DistroWatch" "Linux distro release announcments" (spawn (myBrowser ++ "https://distrowatch.com/"))) []
              , Node (TS.TSNode "LXer" "LXer linux news aggregation" (spawn (myBrowser ++ "http://lxer.com"))) []
              , Node (TS.TSNode "OMG Ubuntu" "Ubuntu news, apps and reviews" (spawn (myBrowser ++ "https://www.omgubuntu.co.uk"))) []
              ]
          , Node (TS.TSNode "+ Window Managers" "window manager documentation" (return ()))
              [ Node (TS.TSNode "+ XMonad" "xmonad documentation" (return ()))
                  [ Node (TS.TSNode "XMonad" "Homepage for XMonad" (spawn (myBrowser ++ "http://xmonad.org"))) []
                  , Node (TS.TSNode "XMonad GitHub" "The GitHub page for XMonad" (spawn (myBrowser ++ "https://github.com/xmonad/xmonad"))) []
                  , Node (TS.TSNode "xmonad-contrib" "Third party extensions for XMonad" (spawn (myBrowser ++ "https://hackage.haskell.org/package/xmonad-contrib"))) []
                  , Node (TS.TSNode "xmonad-ontrib GitHub" "The GitHub page for xmonad-contrib" (spawn (myBrowser ++ "https://github.com/xmonad/xmonad-contrib"))) []
                  , Node (TS.TSNode "Xmobar" "Minimal text-based status bar"  (spawn (myBrowser ++ "https://hackage.haskell.org/package/xmobar"))) []
                  ]
              ]
          ]
      , Node (TS.TSNode "+ Emacs" "Emacs documentation" (return ()))
          [ Node (TS.TSNode "GNU Emacs" "Extensible free/libre text editor" (spawn (myBrowser ++ "https://www.gnu.org/software/emacs/"))) []
          , Node (TS.TSNode "Doom Emacs" "Emacs distribution with sane defaults" (spawn (myBrowser ++ "https://github.com/hlissner/doom-emacs"))) []
          , Node (TS.TSNode "r/emacs" "M-x emacs-reddit" (spawn (myBrowser ++ "https://www.reddit.com/r/emacs/"))) []
          , Node (TS.TSNode "EmacsWiki" "EmacsWiki Site Map" (spawn (myBrowser ++ "https://www.emacswiki.org/emacs/SiteMap"))) []
          , Node (TS.TSNode "Emacs StackExchange" "Q&A site for emacs" (spawn (myBrowser ++ "https://emacs.stackexchange.com/"))) []
          ]
      , Node (TS.TSNode "+ Search and Reference" "Search engines, indices and wikis" (return ()))
          [ Node (TS.TSNode "DuckDuckGo" "Privacy-oriented search engine" (spawn (myBrowser ++ "https://duckduckgo.com/"))) []
          , Node (TS.TSNode "Google" "The evil search engine" (spawn (myBrowser ++ "http://www.google.com"))) []
          , Node (TS.TSNode "Thesaurus" "Lookup synonyms and antonyms" (spawn (myBrowser ++ "https://www.thesaurus.com/"))) []
          , Node (TS.TSNode "Wikipedia" "The free encyclopedia" (spawn (myBrowser ++ "https://www.wikipedia.org/"))) []
          ]
      , Node (TS.TSNode "+ Programming" "programming and scripting" (return ()))
          [ Node (TS.TSNode "+ Bash and Shell Scripting" "shell scripting documentation" (return ()))
              [ Node (TS.TSNode "GNU Bash" "Documentation for bash" (spawn (myBrowser ++ "https://www.gnu.org/software/bash/manual/"))) []
              , Node (TS.TSNode "r/bash" "Subreddit for bash" (spawn (myBrowser ++ "https://www.reddit.com/r/bash/"))) []
              , Node (TS.TSNode "r/commandline" "Subreddit for the command line" (spawn (myBrowser ++ "https://www.reddit.com/r/commandline/"))) []
              , Node (TS.TSNode "Learn Shell" "Interactive shell tutorial" (spawn (myBrowser ++ "https://www.learnshell.org/"))) []
              ]
        , Node (TS.TSNode "+ Elisp" "emacs lisp documentation" (return ()))
            [ Node (TS.TSNode "Emacs Lisp" "Reference manual for elisp" (spawn (myBrowser ++ "https://www.gnu.org/software/emacs/manual/html_node/elisp/"))) []
            , Node (TS.TSNode "Learn Elisp in Y Minutes" "Single webpage for elisp basics" (spawn (myBrowser ++ "https://learnxinyminutes.com/docs/elisp/"))) []
            , Node (TS.TSNode "r/Lisp" "Subreddit for lisp languages" (spawn (myBrowser ++ "https://www.reddit.com/r/lisp/"))) []
            ]
        , Node (TS.TSNode "+ Haskell" "haskell documentation" (return ()))
            [ Node (TS.TSNode "Haskell.org" "Homepage for haskell" (spawn (myBrowser ++ "http://www.haskell.org"))) []
            , Node (TS.TSNode "Hoogle" "Haskell API search engine" (spawn "https://hoogle.haskell.org/")) []
            , Node (TS.TSNode "r/haskell" "Subreddit for haskell" (spawn (myBrowser ++ "https://www.reddit.com/r/Python/"))) []
            , Node (TS.TSNode "Haskell on StackExchange" "Newest haskell topics on StackExchange" (spawn (myBrowser ++ "https://stackoverflow.com/questions/tagged/haskell"))) []
            ]
        , Node (TS.TSNode "+ Python" "python documentation" (return ()))
            [ Node (TS.TSNode "Python.org" "Homepage for python" (spawn (myBrowser ++ "https://www.python.org/"))) []
            , Node (TS.TSNode "r/Python" "Subreddit for python" (spawn (myBrowser ++ "https://www.reddit.com/r/Python/"))) []
            , Node (TS.TSNode "Python on StackExchange" "Newest python topics on StackExchange" (spawn (myBrowser ++ "https://stackoverflow.com/questions/tagged/python"))) []
            ]
        ]
      , Node (TS.TSNode "+ Vim" "vim and neovim documentation" (return ()))
          [ Node (TS.TSNode "Vim.org" "Vim, the ubiquitous text editor" (spawn (myBrowser ++ "https://www.vim.org/"))) []
          , Node (TS.TSNode "r/Vim" "Subreddit for vim" (spawn (myBrowser ++ "https://www.reddit.com/r/vim/"))) []
          , Node (TS.TSNode "Vi/m StackExchange" "Vi/m related questions" (spawn (myBrowser ++ "https://vi.stackexchange.com/"))) []
          ]
      ]
  ]

tsDefaultConfig :: TS.TSConfig a
tsDefaultConfig = TS.TSConfig { TS.ts_hidechildren = True
                              , TS.ts_background   = 0xdd282c34
                              , TS.ts_font         = myFont
                              , TS.ts_node         = (0xffd0d0d0, 0xff1c1f24)
                              , TS.ts_nodealt      = (0xffd0d0d0, 0xff282c34)
                              , TS.ts_highlight    = (0xffffffff, 0xff755999)
                              , TS.ts_extra        = 0xffd0d0d0
                              , TS.ts_node_width   = 200
                              , TS.ts_node_height  = 20
                              , TS.ts_originX      = 100
                              , TS.ts_originY      = 100
                              , TS.ts_indent       = 40
                              , TS.ts_navigate     = myTreeNavigation
                              }

-- myTreeNavigation :: M.Map (KeyMask, KeySym) (TreeSelect a (Maybe a))
myTreeNavigation = M.fromList
    [ ((0, xK_Escape),   TS.cancel)
    , ((0, xK_Return),   TS.select)
    , ((0, xK_space),    TS.select)
    , ((0, xK_Up),       TS.movePrev)
    , ((0, xK_Down),     TS.moveNext)
    , ((0, xK_Left),     TS.moveParent)
    , ((0, xK_Right),    TS.moveChild)
    , ((0, xK_k),        TS.movePrev)
    , ((0, xK_j),        TS.moveNext)
    , ((0, xK_h),        TS.moveParent)
    , ((0, xK_l),        TS.moveChild)
    , ((0, xK_o),        TS.moveHistBack)
    , ((0, xK_i),        TS.moveHistForward)
    , ((0, xK_a),        TS.moveTo ["+ Accessories"])
    , ((0, xK_s),        TS.moveTo ["+ System"])
    , ((0, xK_p),        TS.moveTo ["+ Programming"])
    , ((mod4Mask, xK_l), TS.moveTo ["+ Bookmarks", "+ Linux"])
    , ((mod4Mask, xK_e), TS.moveTo ["+ Bookmarks", "+ Emacs"])
    , ((mod4Mask, xK_s), TS.moveTo ["+ Bookmarks", "+ Search and Reference"])
    , ((mod4Mask, xK_p), TS.moveTo ["+ Bookmarks", "+ Programming"])
    , ((mod4Mask, xK_v), TS.moveTo ["+ Bookmarks", "+ Vim"])
    ]

----------------------------------------------------------------------------}}}
-- XPrompt                                                                  {{{
-------------------------------------------------------------------------------
dtXPConfig :: XPConfig
dtXPConfig = def
    { font                 = myFont
    , fgColor              = "#bbc2cf"
    , bgColor              = "#282c34"
    , fgHLight             = "#000000"
    , bgHLight             = "#c792ea"
    , borderColor          = "#535974"
    , promptBorderWidth    = 0
    , promptKeymap         = dtXPKeymap
    , position             = Top
    , height               = 23
    , historySize          = 256
    , historyFilter        = id
    , defaultText          = []
    , autoComplete         = Just 100000
    , showCompletionOnTab  = False
    , searchPredicate      = fuzzyMatch
    , defaultPrompter      = id $ map toUpper
    , alwaysHighlight      = True
    , maxComplRows         = Nothing
    }
dtXPConfig' :: XPConfig
dtXPConfig' = dtXPConfig
    { autoComplete         = Nothing
    }
dtXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
dtXPKeymap = M.fromList $
    map (first $ (,) controlMask)     -- control + <key>
    [ (xK_z, killBefore)              -- kill line backwards
    , (xK_k, killAfter)               -- kill line forwards
    , (xK_a, startOfLine)             -- move to the beginning of the line
    , (xK_e, endOfLine)               -- move to the end of the line
    , (xK_m, deleteString Next)       -- delete a character forward
    , (xK_b, moveCursor Prev)         -- move cursor forward
    , (xK_b, moveCursor Next)         -- move cursor backward
    , (xK_BackSpace, killWord Prev)   -- kill the previous word
    , (xK_y, pasteString)             -- paste a string
    , (xK_q, quit)                    -- quit out of prompt
    , (xK_bracketleft, quit)
    ]
    ++
    map (first $ (,) altMask)          -- meta key + <key>
    [ (xK_BackSpace, killWord Prev)    -- kill the prev word
    , (xK_f, moveWord Next)            -- move a word forward
    , (xK_b, moveWord Prev)            -- move a word backword
    , (xK_d, killWord Next)            -- kill the next word
    , (xK_n, moveHistory W.focusUp')   -- move up thru history
    , (xK_p, moveHistory W.focusDown') -- move down thru history
    ]
    ++
    map (first $ (,) 0) -- <key>
    [ (xK_Return, setSuccess True >> setDone True)
    , (xK_KP_Enter, setSuccess True >> setDone True)
    , (xK_BackSpace, deleteString Prev)
    , (xK_Delete, deleteString Next)
    , (xK_Left, moveCursor Prev)
    , (xK_Right, moveCursor Next)
    , (xK_Home, startOfLine)
    , (xK_End, endOfLine)
    , (xK_Down, moveHistory W.focusUp')
    , (xK_Up, moveHistory W.focusDown')
    , (xK_Escape, quit)
    ]

-- -- Calc
-- calcPrompt c ans =
--     imputPrompt c (trim ans) ?+ \input ->
--         liftIO(runProcessWithInput "qalc" [input] "") >>== calcPrompt c
--     where
--         trim = f . f
--             where f = reverse . dropWhile isSpace

-- Edit
editPrompt :: String -> X ()
editPrompt home = do
    str <- inputPrompt cfg "EDIT: ~/"
    case str of
        Just s  -> openInEditor s
        Nothing -> pure ()
  where
    cfg = dtXPConfig { defaultText = "" }

openInEditor :: String -> X ()
openInEditor path =
    safeSpawn "emacsclient" ["-c", "-a", "emacs", path]

scrotPrompt :: String -> Bool -> X ()
scrotPrompt home select = do
    str <- inputPrompt cfg "~/scrot/"
    case str of
        Just s -> spawn $ printf "sleep 0.3 && scrot %s '%s' -e 'mv $f ~/scrot'" mode s
        Nothing -> pure ()
    where
        mode = if select then "--select" else "--focused"
        cfg = dtXPConfig { defaultText = "" }



----------------------------------------------------------------------------}}}
-- Search Engines                                                           {{{
-------------------------------------------------------------------------------

archwiki, news, reddit :: S.SearchEngine

archwiki = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
news     = S.searchEngine "news" "https://news.google.com/search?q="
reddit   = S.searchEngine "reddit" "https://www.reddit.com/search/?q="

searchList :: [(String, S.SearchEngine)]
searchList = [ ("a", archwiki)
             , ("n", news)
             , ("r", reddit)
             ]

----------------------------------------------------------------------------}}}
-- ScratchPads                                                              {{{
-------------------------------------------------------------------------------

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                -- , NS "mocp" spawnMocp findMocp manageMocp
                ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnMocp  = myTerminal ++ " -n mocp 'mocp'"
    findMocp   = resource =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w

-- Spacing
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

----------------------------------------------------------------------------}}}
-- Hooks                                                                    {{{
-------------------------------------------------------------------------------
tall     = renamed [Replace "tall"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 4
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 4
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ mySpacing' 2
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ mySpacing' 2
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           $ tabbed shrinkText myTabTheme

myTabTheme = def { fontName            = myFont
                  , activeColor         = "#46d9ff"
                  , inactiveColor       = "#313846"
                  , activeBorderColor   = "#46d9ff"
                  , inactiveBorderColor = "#282c34"
                  , activeTextColor     = "#282c34"
                  , inactiveTextColor   = "#d0d0d0"
                  }

myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font          = myFont
    , swn_fade          = 1.0
    , swn_bgcolor       = "#1c1f24"
    , swn_color         = "#ffffff"
    }

myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     tall
                                 ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow

myWorkspaces :: [String]
myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]
-- myWorkspaces = map show [1..9]


xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myClickableWorkspaces :: [String]
myClickableWorkspaces = clickable . (map xmobarEscape)
              $ [" dev", " www",  " sys", " doc", " vbox", " chat", " mus", " vid", " gfx "]
    where
        clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]

-- Whenever a new window is created, xmonad calls the manageHook,
-- which can thus be used to perform certain actions on the new window,
-- such as placing it in a specific workspace, ignoring it, or placing it in the float layer.
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
    -- using 'doShift (myWorkspaces !! 7)' sends program to workspace 8!
    [ title =? "Mozilla Firefox"      --> doShift (myWorkspaces !! 1)
    , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat
    -- className =? "firefox" --> doF (W.shift "www") -- TODO
    -- , className =? "mpv"              --> doShift (myWorkspaces !! 7)
    , className =? "Oracle VM VirtualBox Manager"  --> doFloat
    ] <+> namedScratchpadManageHook myScratchPads

myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 1.0
