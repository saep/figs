{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

module Main where

import Control.Lens
import Data.Generics.Labels ()
import Data.Generics.Product ()
import Data.Generics.Sum ()
import qualified Data.List.PointedList.Circular as PList
import qualified Data.Map.Strict as Map
import Data.Ratio ((%))
import qualified Data.Set as Set
import Data.Tree as Tree
import MyWorkspaces
import Network.HostName (getHostName)
import Numeric.Lens (hex)
import Relude
import XMonad hiding (mapped, whenJust)
import qualified XMonad.Actions.DynamicWorkspaces as DW
import qualified XMonad.Actions.Search as Search
import XMonad.Actions.TreeSelect (TSConfig (..), TSNode (..), treeselectAction)
import qualified XMonad.Actions.TreeSelect as Tree
import XMonad.Actions.WindowGo (raiseNextMaybe)
import XMonad.Hooks.EwmhDesktops as EWMH
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.WorkspaceHistory
import XMonad.Layout.ComboP
import XMonad.Layout.Fullscreen as Full
import qualified XMonad.Layout.IM as IM
import XMonad.Layout.LayoutHints
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.OnHost
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Tabbed
import XMonad.Layout.TrackFloating
import XMonad.Layout.TwoPane
import XMonad.Layout.WorkspaceDir
import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch (fuzzyMatch, fuzzySort)
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Window (WindowPrompt (..), allWindows, windowMultiPrompt)
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeysP, removeKeysP, parseKey)
import qualified XMonad.Util.ExtensibleState as XS
import XMonad.Util.Hacks (javaHack)
import XMonad.Util.NamedScratchpad (NamedScratchpad (..), customFloating, namedScratchpadManageHook, namedScratchpadAction)
import XMonad.Util.Parser (runParser, eof)
import XMonad.Util.Run
import XMonad.Util.WorkspaceCompare (getSortByIndex)

main :: IO ()
main = do
  myConfig <- initMyConfig
  xmonad . javaHack . ewmh . docks $ applyMyConfig myConfig

type KeyChord = String

data MyConfig = MyConfig
  { myTerminal :: String,
    myKeys :: [(KeyChord, X ())]
  }
  deriving (Generic)

instance Default MyConfig where
  def =
    let myDynamicWorkspaceKeys = do
          k <- Set.toList $ Map.keysSet $ actionByKey initialValue
          [ ("M-" <> unKey k, dynamicWorkspace k W.greedyView),
            ("M-S-" <> unKey k, dynamicWorkspace k W.shift)
            ]
        myScreenKeys = do
          (k, sc) <- zip ["w", "e", "r"] [0 ..]
          [ ("M-" <> k, screenWorkspace sc >>= flip whenJust (windows . W.view)),
            ("M-S-" <> k, screenWorkspace sc >>= flip whenJust (windows . W.shift))
            ]
     in MyConfig
          { myTerminal = "kitty",
            myKeys =
              myDynamicWorkspaceKeys
                <> myScreenKeys
                <> [ ("M-g", sendMessage ToggleStruts),
                     ("M-f", myTreeselectWorkspace myTSConfig W.greedyView),
                     ("M-n", namedScratchpadAction scratchpads "keepassxc"),
                     ("M-S-f", myTreeselectWorkspace myTSConfig W.shift),
                     ("M-q", treeSelectKey),
                     ("M-t", XS.get >>= spawn . myTerminal),
                     ("M-o", myPromptsPrompt),
                     ("M-s", withFocused $ windows . W.sink),
                     ("M-p", shellPrompt myPrompt),
                     ("M-a", myWorkspacePrompt),
                     ("M-y", treeSelectChromeApps),
                     ("M-<Tab>", cycleAtCurrentTreeLevel Next),
                     ("M-S-<Tab>", cycleAtCurrentTreeLevel Prev)
                   ]
          }

cycleScreens :: X ()
cycleScreens = do
  windowset' <- gets windowset
  let workspaceName = W.tag . W.workspace
      firstNonFocuesVisibleWorkspace = viaNonEmpty head . fmap workspaceName $ W.visible windowset'
  whenJust firstNonFocuesVisibleWorkspace $ windows . W.view

cycleAtCurrentTreeLevel :: Direction1D -> X ()
cycleAtCurrentTreeLevel dir = do
  wset <- gets windowset
  myWorkspaces <- XS.get :: X (Workspaces MyWorkspace)
  let currentWorkspace = W.tag . W.workspace . W.current $ wset
      moveFocus = if dir == Next then PList.next else PList.previous
      nextWorkspace =
        view PList.focus
          . moveFocus
          $ siblingsWithCurrentWorkspaceAsFocus myWorkspaces wset currentWorkspace
  windows $ W.greedyView nextWorkspace

instance ExtensionClass MyConfig where
  initialValue = def

initMyConfig :: IO MyConfig
initMyConfig =
  getHostName >>= \case
    "swaep" -> do
      pure
        def
          { myKeys =
              myKeys def
                <> [ ("<XF86MonBrightnessUp>", safeSpawn "xbacklight" ["-inc", "5"]),
                     ("<XF86MonBrightnessDown>", safeSpawn "xbacklight" ["-dec", "5"]),
                     -- no media keys on swaep
                     ("M-<XF86AudioLowerVolume>", safeSpawn "mpc" ["prev"]),
                     ("M-<XF86AudioRaiseVolume>", safeSpawn "mpc" ["next"]),
                     ("M-<XF86AudioMute>", safeSpawn "mpc" ["toggle"])
                   ]
          }
    _ -> do
      pure def

myTheme :: Theme
myTheme =
  def
    { activeTextColor = "#b58900",
      activeColor = "#545454",
      activeBorderColor = "#545454",
      inactiveColor = "#293134",
      inactiveTextColor = "#e8e2b7",
      inactiveBorderColor = "#293134",
      urgentTextColor = "#dc322f",
      urgentColor = "#678cb1",
      urgentBorderColor = "#dc322f",
      fontName = "xft:Fira Code:size=12"
    }

myTSConfig :: Tree.TSConfig a
myTSConfig =
  let hexStrToWord :: String -> Word64
      hexStrToWord ('#' : str) = fromMaybe 0 $ str ^? hex
      hexStrToWord _ = 0
      f color = hexStrToWord $ color myTheme
   in def
        { ts_font = fontName myTheme,
          ts_background = f inactiveColor,
          ts_highlight = (f urgentTextColor, f urgentColor),
          ts_node = (f inactiveTextColor, f activeColor),
          ts_nodealt = (f inactiveTextColor, f inactiveColor),
          ts_extra = f activeTextColor
        }

myLayout ws =
  trackFloating
    . useTransientFor
    . layoutHintsToCenter
    . onWorkspace (myFullWorkspaceId Mehl) (workspaceDir "~/Documents" tab)
    . onWorkspace (myFullWorkspaceId Dev) ((dev ||| tab) `ifUltraWideScreenOrElse` tab)
    . onWorkspace (myFullWorkspaceId Emacs) (workspaceDir "~/src/org" full)
    . onWorkspace (myFullWorkspaceId IM) (tall ||| im)
    . onWorkspace (myFullWorkspaceId Browser) (workspaceDir "~/Downloads" ((tall ||| full) `ifUltraWideScreenOrElse` (full ||| tall)))
    $ tall ||| tab ||| full
  where
    ifUltraWideScreenOrElse = onHosts ["monoid", "pc2-switte"]
    myFullWorkspaceId w = ws ^. workspaceIdOf (Name w)
    full = smartBorders Full
    tab = noBorders . avoidStruts $ tabbed shrinkText myTheme
    dev = combineTwoP (TwoPane 0.03 0.6) tab tall (Or (ClassName "jetbrains-idea") (ClassName "Emacs"))
    tall = avoidStruts $ smartBorders $ layoutHints $ mouseResizableTile {draggerType = FixedDragger 2 6}
    im =
      let signalDesktop = Full
          gajim = IM.gridIM (1 % 4) (Role "roster")
       in avoidStruts $
            combineTwoP
              (TwoPane 0.03 0.4)
              signalDesktop
              gajim
              (ClassName "Signal")

data MyWorkspace
  = Root
  | Dev
  | Emacs
  | Social
  | IM
  | Mehl
  | Web
  | Browser
  | Youtube
  | Netflix
  | Misc
  | N6
  | N7
  | N8
  | N9
  deriving (Show, Read, Eq, Ord, Enum, Bounded, Generic)

myWorkspaceNodeIds :: Iso' (Name MyWorkspace) String
myWorkspaceNodeIds = mkWorkspaceNodeIdIso

instance WorkspaceNodeId MyWorkspace where
  workspaceNodeId = myWorkspaceNodeIds
  defaultTree =
    let node ws = Node (mkWorkspace ws)
        nodeWithKey ws k = Node (mkWorkspace ws & #key ?~ k)
     in node
          Root
          [ node
              Web
              [ nodeWithKey Browser "b" [],
                node Youtube [],
                node Netflix []
              ],
            nodeWithKey Dev "d" [],
            nodeWithKey Emacs "u" [],
            node
              Social
              [ nodeWithKey Mehl "m" [],
                nodeWithKey IM "i" []
              ],
            node
              Misc
              (zipWith (\n k -> nodeWithKey n (show k) []) [N6 .. N9] [6 :: Word8 ..])
          ]

data MyPrompt = MyPrompt
  { name :: String,
    action :: X ()
  }
  deriving (Generic)

myPrompts :: [MyPrompt]
myPrompts =
  [ MyPrompt "window" (windowMultiPrompt auto [(Goto, allWindows), (Bring, allWindows)]),
    MyPrompt "hoogle" (Search.promptSearch select Search.hoogle),
    MyPrompt "google" (Search.promptSearch select Search.google),
    MyPrompt "duckduckgo" (Search.promptSearch select Search.duckduckgo),
    MyPrompt "wikipedia" (Search.promptSearch select Search.wikipedia)
  ]
  where
    auto = myPrompt
    select = myPrompt {autoComplete = Nothing, alwaysHighlight = False}

data WorkspacePromptMode = View | Create | Delete
  deriving (Eq, Ord, Bounded, Enum)

data WorkspacePrompt = WorkspacePrompt
  { mode :: WorkspacePromptMode,
    existingWorkspaces :: [WorkspaceId],
    currentWorkspace :: WorkspaceId
  }

instance XPrompt WorkspacePrompt where
  showXPrompt (WorkspacePrompt {..}) =
    case mode of
      View -> "View workspace: "
      Create -> "Create workspace: "
      Delete -> "Delete workspace: "

  completionFunction (WorkspacePrompt {..}) = case mode of
    View -> pure . fuzzyMatchOneOf existingWorkspaces
    Create -> pure . (: [currentWorkspace])
    Delete -> pure . fuzzyMatchOneOf existingWorkspaces

  modeAction (WorkspacePrompt {..}) _completed input = case mode of
    View -> windows $ W.greedyView input
    Create -> DW.addWorkspace input
    Delete -> DW.removeWorkspaceByTag input

myWorkspacePrompt :: X ()
myWorkspacePrompt = do
  existingWorkspaces <- map W.tag <$> (getSortByIndex <*> gets (W.workspaces . windowset))
  currentWorkspace <- gets (W.currentTag . windowset)
  let modes = (\mode -> XPT $ WorkspacePrompt {..}) <$> [minBound .. maxBound]
  let select' =
        myPrompt
          { searchPredicate = searchPredicate def,
            sorter = sorter def,
            alwaysHighlight = False,
            autoComplete = autoComplete def
          }
  mkXPromptWithModes modes select'

data Prompt = Prompt

instance XPrompt Prompt where
  showXPrompt _ = "Prompt: "

fuzzyMatchOneOf :: [String] -> String -> [String]
fuzzyMatchOneOf choices input =
  fuzzySort input $ filter (fuzzyMatch input) choices

myPromptsPrompt :: X ()
myPromptsPrompt = mkXPrompt Prompt myPrompt compl action
  where
    actions = Map.fromList $ map mkAction myPrompts
    mkAction p = (p ^. #name, p ^. #action)
    compl = pure . fuzzyMatchOneOf (Map.keys actions)
    action selection = Map.findWithDefault (pure ()) selection actions

applyMyConfig myConfig@MyConfig {..} =
  let myWorkspaces = mkWorkspaces @MyWorkspace
   in def
        { modMask = mod4Mask,
          focusFollowsMouse = False,
          clickJustFocuses = False,
          focusedBorderColor = activeTextColor myTheme,
          normalBorderColor = activeColor myTheme,
          startupHook = do
            XS.put myConfig
            startupHook def,
          handleEventHook =
            mconcat
              [ Full.fullscreenEventHook,
                hintsEventHook
              ],
          workspaces = Tree.toWorkspaces $ toTreeSelectWorkspaces myWorkspaces,
          logHook = workspaceHistoryHook,
          layoutHook = myLayout myWorkspaces,
          manageHook = myManageHook
        }
        `additionalKeysP` myKeys
        `removeKeysP` ["M-S-q"]

scratchpads :: [NamedScratchpad]
scratchpads = 
  [ NS "keepassxc" "keepassxc" (className =? "KeePassXC") (customFloating $ W.RationalRect (1/3) (1/4) (1/3) (1/2))
  ]

myManageHook :: ManageHook
myManageHook = composeAll chromeApps <> insertPosition Below Newer <> namedScratchpadManageHook scratchpads
  where
    myWorkspaces = mkWorkspaces
    chromeApps = mapMaybe moveChromeAppToWorkspace myChromeApps
    moveChromeAppToWorkspace app = do
      myWs <- app ^. #workspace
      let ws = myWorkspaces ^. workspaceIdOf (Name myWs)
      pure (isSameChromeApp app --> doShift ws)

data ChromeApp = ChromeApp
  { name :: String,
    url :: String,
    key :: KeyChord,
    workspace :: Maybe MyWorkspace
  }
  deriving (Generic, Show)

myChromeApps :: [ChromeApp]
myChromeApps =
  [ ChromeApp "Youtube" "www.youtube.com" "y" (Just Youtube),
    ChromeApp "zulip" "zulip.logproit.de" "z" (Just IM),
    ChromeApp "netflix" "www.netflix.com" "n" (Just Netflix),
    ChromeApp "Office LogProIT" "www.office365.com" "l" (Just Mehl)
  ]

isSameChromeApp :: ChromeApp -> Query Bool
isSameChromeApp app = appName =? (app ^. #url)

treeSelectChromeApps :: X ()
treeSelectChromeApps = do
  treeselectAction cfg (toNode <$> myChromeApps)
  where
    toTSNode app = TSNode (app ^. #name) ("[" <> (app ^. #key) <> "] " <> (app ^. #url)) (startChromeApp app)
    toNode = flip Node [] . toTSNode
    startChromeApp :: ChromeApp -> X ()
    startChromeApp app =
      raiseNextMaybe
        (safeSpawn "chromium" ["--app=https://" <> app ^. #url])
        (isSameChromeApp app)
    cfg = myTSConfig {ts_navigate = ts_navigate myTSConfig <> appKeys}
    toBinding app = case runParser (parseKey <* eof) (app ^. #key) of
      Just k -> Just ((0 :: KeyMask, k), Tree.moveTo [app ^. #name])
      _ -> Nothing
    appKeys = Map.fromList $ mapMaybe toBinding myChromeApps

myPrompt :: XPConfig
myPrompt =
  def
    { changeModeKey = xK_semicolon,
      font = fontName myTheme,
      sorter = fuzzySort,
      searchPredicate = fuzzyMatch,
      fgColor = activeTextColor myTheme,
      bgColor = activeColor myTheme,
      fgHLight = urgentTextColor myTheme,
      bgHLight = urgentColor myTheme,
      alwaysHighlight = True,
      autoComplete = Just 25000,
      height = 32,
      maxComplRows = Just 1
    }

newtype DynamicWorkspaceKeys = DynamicWorkspaceKeys
  { actionByKey :: Map Key (Maybe WorkspaceId)
  }
  deriving (Show, Read, Generic)

treeSelectKey :: X ()
treeSelectKey = do
  keysAndWorkspaces <- XS.gets (Map.toList . actionByKey)
  currentWorkspace <- gets (W.currentTag . windowset)
  treeselectAction (cfg keysAndWorkspaces) (toNode currentWorkspace <$> keysAndWorkspaces)
  where
    cfg keysAndWorkspaces = myTSConfig {ts_navigate = ts_navigate myTSConfig <> wsKeys keysAndWorkspaces}
    toNode currentWorkspace = flip Node [] . toTsNode currentWorkspace
    toTsNode currentWorkspace (key, maybeWs) =
      let assignKey = XS.modify @DynamicWorkspaceKeys $ #actionByKey . at key ?~ Just currentWorkspace
       in TSNode (unKey key) (fromMaybe "" maybeWs) assignKey
    toBinding (Key key) = case runParser parseKey key of
      Just k -> do
        pure ((0 :: KeyMask, k), Tree.moveTo [key])
      _ -> Nothing
    wsKeys = Map.fromList . mapMaybe (toBinding . fst)

instance ExtensionClass DynamicWorkspaceKeys where
  initialValue =
    let myWorkspaces = mkWorkspaces @MyWorkspace
        workspaceKeys = do
          ws <- Tree.flatten $ myWorkspaces ^. #workspaces
          key <- maybeToList $ ws ^. #key
          let wsId = myWorkspaces ^. workspaceIdOf (ws ^. #name)
          pure (key, Just wsId)
     in DynamicWorkspaceKeys . Map.fromList $
          workspaceKeys <> map (\i -> (show i, Nothing)) [1 .. 5 :: Word8]
  extensionType = PersistentExtension

dynamicWorkspace :: Key -> (WorkspaceId -> WindowSet -> WindowSet) -> X ()
dynamicWorkspace k f = do
  workspaceForKey <- XS.gets (join . Map.lookup k . actionByKey)
  whenJust workspaceForKey $ windows . f
