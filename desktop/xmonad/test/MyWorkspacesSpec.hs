{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

module MyWorkspacesSpec where

import Control.Lens
import qualified Data.List.PointedList.Circular as PL
import qualified Data.Set as Set
import Data.Tree
import MyWorkspaces
import Relude
import Test.Hspec
import XMonad
import XMonad.Actions.TreeSelect
import qualified XMonad.StackSet as W

data WS = Root | L1A | L1B | L1C | L2A | L2B | L3A1 | L3A2
    deriving (Show, Eq, Ord, Enum, Bounded)

isoWS :: Iso' (Name WS) String
isoWS = mkWorkspaceNodeIdIso

instance WorkspaceNodeId WS where
    workspaceNodeId = isoWS
    defaultTree =
        node
            Root
            [ node
                L1A
                [ node
                    L2A
                    [ node L3A1 []
                    , node L3A2 []
                    ]
                ]
            , node
                L1B
                [ node L2B []
                ]
            , node L1C []
            ]

node :: WS -> Forest (Workspace WS) -> Tree (Workspace WS)
node ws = Node (mkWorkspace ws)

myWorkspaceTree :: Workspaces WS
myWorkspaceTree = mkWorkspaces

testWindowSet :: WindowSet
testWindowSet =
    let mkWs ws =
            W.Workspace
                { W.tag = toTag ws
                , W.layout = error "no layout defined"
                , W.stack = Just $ W.Stack aWindow [] []
                }
        toTag ws = myWorkspaceTree ^. workspaceIdOf (Name ws)
        aWindow = 0
        someScreenDetails = SD (Rectangle 0 0 1920 1080)
     in W.StackSet
            { W.current = W.Screen (mkWs L3A1) 0 someScreenDetails
            , W.visible = [W.Screen (mkWs L1C){W.stack = Nothing} 1 someScreenDetails]
            , W.hidden = map mkWs $ filter (not . (`Set.member` [L3A1, L1C])) [minBound .. maxBound]
            , W.floating = []
            }

spec :: Spec
spec = do
    describe "Key fromString" $ do
        let forcedFromString' :: String -> IO ()
            forcedFromString' str = when (fromString str == Key "") (pure ())
        it "parses <Esc>" $ do
            fromString "<Esc>" `shouldBe` Key "<Esc>"
        it "parses 1" $ do
            fromString "1" `shouldBe` Key "1"
        it "doesn't parse <Esc" $ do
            forcedFromString' "<Esc" `shouldThrow` anyErrorCall
        it "doesn't parse modifiers" $ do
            forcedFromString' "M-s" `shouldThrow` anyErrorCall
    describe "indexed workspace lens" $ do
        it "returns root if the path is empty" $ do
            myWorkspaceTree ^. at mempty `shouldBe` Just (myWorkspaceTree ^. #workspaces)
        it "returns the node at the given path" $ do
            myWorkspaceTree ^. at (pathFromRoot [L1A, L2A]) `shouldBe` Just (node L2A [node L3A1 [], node L3A2 []])
        it "only returns valid paths" $ do
            myWorkspaceTree ^. at (pathFromRoot [L3A2]) `shouldBe` Nothing
        it "does nothing for empty path" $ do
            let emptiedTree = myWorkspaceTree & sans mempty
            emptiedTree `shouldBe` myWorkspaceTree
        it "replaces at the given path" $ do
            let replaced = myWorkspaceTree & ix (pathFromRoot [L1A]) %~ #subForest .~ []
            replaced ^. at (pathFromRoot [L1A]) `shouldBe` Just (node L1A [])
        it "deletes the node at the given path" $ do
            let withoutL2A = myWorkspaceTree & sans (pathFromRoot [L1A, L2A])
            withoutL2A ^. ix (pathFromRoot [L1A]) . #subForest `shouldBe` []
        it "doesn't delete anything if path doesn't exist" $ do
            (myWorkspaceTree & sans (pathFromRoot [L3A2])) `shouldBe` myWorkspaceTree
    describe "workspaceId" $ do
        it "returns the workspace node name for a path of length 1" $ do
            pathFromRoot [L1A] ^. workspaceId `shouldBe` "L1A"
            "L1A" ^. from workspaceId `shouldBe` pathFromRoot [L1A]
        it "joins path segments with a dot" $ do
            pathFromRoot [L1A, L2A] ^. workspaceId `shouldBe` "L1A.L2A"
            "L1A.L2A" ^. from workspaceId `shouldBe` pathFromRoot [L1A, L2A]
        it "returns empty string for an empty path" $ do
            (mempty :: PathFromRoot WS) ^. workspaceId `shouldBe` ""
            "" ^. from workspaceId `shouldBe` pathFromRoot @WS []
        it "handles custom path segments" $ do
            PathFromRoot [Name L1A, WsId "custom"] ^. workspaceId `shouldBe` "L1A.custom"
            "L1A.custom" ^. from workspaceId `shouldBe` PathFromRoot [Name L1A, WsId "custom"]
    describe "parent" $ do
        it "returns Nothing if path is empty" $ do
            (mempty :: PathFromRoot WS) ^. parent `shouldBe` Nothing
        it "returns the init of a path if not empty" $ do
            pathFromRoot [L1A, L2A, L3A1] ^. parent `shouldBe` Just (pathFromRoot [L1A, L2A])
    describe "path" $ do
        it "reverses order" $ do
            pathFromRoot [L1A, L2A] ^. path `shouldBe` pathToRoot [L2A, L1A]
            pathToRoot [L1A, L2A] ^. from path `shouldBe` pathFromRoot [L2A, L1A]
    describe "toTreeSelectWorkspaces" $ do
        it "creates the expected tree" $ do
            let workspaces_ = ["L1A", "L1A.L2A", "L1A.L2A.L3A1", "L1A.L2A.L3A2", "L1B", "L1B.L2B", "L1C"]
            (toWorkspaces . toTreeSelectWorkspaces) myWorkspaceTree `shouldBe` workspaces_
    describe "workspacePaths" $ do
        it "is empty for empty definition" $ do
            workspacePaths (node Root []) `shouldBe` []
        it "returns the expected paths" $ do
            let expectedPaths =
                    [ (Name L1A, pathToRoot [L1A])
                    , (Name L2A, pathToRoot [L2A, L1A])
                    , (Name L3A1, pathToRoot [L3A1, L2A, L1A])
                    , (Name L3A2, pathToRoot [L3A2, L2A, L1A])
                    , (Name L1B, pathToRoot [L1B])
                    , (Name L2B, pathToRoot [L2B, L1B])
                    , (Name L1C, pathToRoot [L1C])
                    ]
            myWorkspaceTree ^. #workspaces . to workspacePaths `shouldBe` expectedPaths
    describe "findSiblings" $ do
        it "returns an empty set if the parent doesn't exist" $ do
            findSiblings myWorkspaceTree "invalid.path" `shouldBe` []
        it "returns children of parent if last path segment is invalid" $ do
            findSiblings myWorkspaceTree "L1A.L2A.invalid" `shouldBe` ["L1A.L2A.L3A1", "L1A.L2A.L3A2"]
        it "finds all the siblings" $ do
            findSiblings myWorkspaceTree "L1A.L2A.L3A1" `shouldBe` ["L1A.L2A.L3A2"]
        it "finds the siblings below the root" $ do
            findSiblings myWorkspaceTree "L1A" `shouldBe` ["L1B", "L1C"]
    describe "siblingsWithCurrentWorkspaceAsFocus" $ do
        let nextNonEmptySibling' =
                view PL.focus . PL.next . siblingsWithCurrentWorkspaceAsFocus myWorkspaceTree testWindowSet
        it "returns the current workspace if there are no siblings " $ do
            nextNonEmptySibling' "L1B.L2B" `shouldBe` "L1B.L2B"
        it "returns a different workspace if a sibling workspace has windows" $ do
            nextNonEmptySibling' "L1A.L2A.L3A1" `shouldBe` "L1A.L2A.L3A2"
        it "only returns workspaces with windows" $ do
            nextNonEmptySibling' "L1A" `shouldBe` "L1B"
            nextNonEmptySibling' "L1B" `shouldBe` "L1A"
    describe "addNewWorkspaceIfNotPresent" $ do
        let newEmptyNode = Node (Workspace (WsId "new") Nothing) []
        it "adds a new workspace below the root if there are no dots in the name" $ do
            let withNew = addNewWorkspaceIfNotPresent "new" myWorkspaceTree
            withNew ^. at ("new" ^. from workspaceId) `shouldBe` Just newEmptyNode
        it "adds a new workspace deep in the tree" $ do
            let withNew = addNewWorkspaceIfNotPresent "very.deep.in.tree.new" myWorkspaceTree
            withNew ^. at ("very.deep.in.tree.new" ^. from workspaceId) `shouldBe` Just newEmptyNode
