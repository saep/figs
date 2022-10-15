{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# OPTIONS_GHC -Wno-redundant-constraints #-}

-- | Organisation of workspaces as a tree.
module MyWorkspaces where

import Control.Lens
import Data.Generics.Labels ()
import qualified Data.List.PointedList.Circular as PL
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Data.String
import Data.Tree
import Data.Tree.Lens
import Relude
import qualified Text.Megaparsec as P
import XMonad hiding (workspaces)
import qualified XMonad.Actions.TreeSelect as TreeSelect
import qualified XMonad.StackSet as W
import XMonad.Util.Parser (runParser, eof)
import XMonad.Util.EZConfig (parseKey)

newtype Key = Key {unKey :: String}
    deriving (Show, Read, Eq, Ord, Generic)

instance IsString Key where
    fromString s = case runParser (parseKey <* eof) s of
        Nothing -> error $ toText s <> " cannot be parsed"
        Just _ -> Key s

data Name name = Name name | WsId WorkspaceId
    deriving (Eq, Ord, Show, Read, Generic)

data Workspace name = Workspace
    { name :: !(Name name)
    , key :: !(Maybe Key)
    }
    deriving (Show, Read, Eq, Generic)

mkWorkspace :: name -> Workspace name
mkWorkspace n = Workspace (Name n) Nothing

class WorkspaceNodeId ws where
    workspaceNodeId :: Iso' (Name ws) String
    defaultTree :: Tree (Workspace ws)

instance WorkspaceNodeId String where
    defaultTree = Node (mkWorkspace "1") []
    workspaceNodeId = iso to' from'
      where
        to' (Name name_) = name_
        to' (WsId name_) = name_
        from' name_ = WsId name_

mkWorkspaceNodeIdIso ::
    (Show ws, Enum ws, Bounded ws, Ord ws) =>
    Iso' (Name ws) String
mkWorkspaceNodeIdIso = iso to' from'
  where
    to' (WsId name_) = name_
    to' name_ = toMap Map.! name_
    from' wsId = Map.findWithDefault (WsId wsId) wsId fromMap
    toMap = Map.fromList $ map (\w -> (Name w, show w)) [minBound .. maxBound]
    fromMap = Map.fromList $ map (\w -> (show w, Name w)) [minBound .. maxBound]

data Workspaces name = Workspaces
    { workspaces :: Tree (Workspace name)
    , pathByName :: Map (Name name) (PathToRoot name)
    }
    deriving (Show, Read, Eq, Generic)

mkWorkspaces' ::
    Ord name =>
    Tree (Workspace name) ->
    Workspaces name
mkWorkspaces' ws = Workspaces ws byName
  where
    byName = Map.fromList $ workspacePaths ws

mkWorkspaces ::
    Ord name =>
    WorkspaceNodeId name =>
    Workspaces name
mkWorkspaces = mkWorkspaces' defaultTree

instance
    (Ord name, Typeable name, WorkspaceNodeId name, Show name, Read name) =>
    ExtensionClass (Workspaces name)
    where
    initialValue = mkWorkspaces
    extensionType = PersistentExtension

workspaceIdOf ::
    Ord name =>
    WorkspaceNodeId name =>
    Name name ->
    Fold (Workspaces name) WorkspaceId
workspaceIdOf name_ = #pathByName . ix name_ . from path . workspaceId

newtype PathFromRoot name = PathFromRoot [Name name]
    deriving (Show, Read, Eq, Generic)
    deriving (Semigroup, Monoid) via [Name name]

pathFromRoot :: [name] -> PathFromRoot name
pathFromRoot = PathFromRoot . map Name

parent ::
    (Profunctor p, Contravariant f) =>
    Optic' p f (PathFromRoot name) (Maybe (PathFromRoot name))
parent = to $ \(PathFromRoot ps) -> PathFromRoot <$> viaNonEmpty init ps

newtype PathToRoot name = PathToRoot [Name name]
    deriving (Show, Read, Eq, Generic)
    deriving (Semigroup, Monoid) via [Name name]

pathToRoot :: [name] -> PathToRoot name
pathToRoot = PathToRoot . map Name

path :: Iso' (PathFromRoot name) (PathToRoot name)
path =
    iso
        (\(PathFromRoot ps) -> PathToRoot (reverse ps))
        (\(PathToRoot ps) -> PathFromRoot (reverse ps))

type instance Index (Workspaces name) = PathFromRoot name

type instance IxValue (Workspaces name) = Tree (Workspace name)

instance (WorkspaceNodeId name, Ord name) => Ixed (Workspaces name)

instance (WorkspaceNodeId name, Ord name) => At (Workspaces name) where
    at (PathFromRoot path') = lens getter setter
      where
        matches pos (Node ws _) = ws ^. #name == pos
        getter Workspaces{workspaces = rootNode} = case path' of
            [] -> pure rootNode
            (pos : toWalk) -> listToMaybe $ concatMap (go pos toWalk) (rootNode ^. #subForest)
          where
            go pos toWalk node = do
                guard (pos `matches` node)
                case toWalk of
                    [] -> pure node
                    (pos' : toWalk') -> do
                        subNode <- node ^. #subForest
                        go pos' toWalk' subNode

        setter :: Workspaces name -> Maybe (Tree (Workspace name)) -> Workspaces name
        setter Workspaces{workspaces = rootNode} toSet = case path' of
            [] -> mkWorkspaces' $ fromMaybe rootNode toSet
            (pos : toWalk) ->
                mkWorkspaces' $
                    rootNode & #subForest
                        %~ ( case toSet of
                                Nothing -> mapMaybe (delete pos toWalk)
                                Just newValue -> addOrSet newValue pos toWalk
                           )
          where
            delete pos toWalk node
                | pos `matches` node = case toWalk of
                    [] -> Nothing
                    (pos' : toWalk') -> pure $ node & #subForest %~ mapMaybe (delete pos' toWalk')
                | otherwise = pure node
            addOrSet newValue pos toWalk = go
              where
                go [] = pure $ case toWalk of
                    [] -> newValue
                    (pos' : toWalk') -> Node (Workspace pos Nothing) (addOrSet newValue pos' toWalk' [])
                go (node : nodes)
                    | pos `matches` node = case toWalk of
                        [] -> newValue : nodes
                        (pos' : toWalk') -> (node & #subForest %~ addOrSet newValue pos' toWalk') : nodes
                    | otherwise = node : go nodes

workspaceId :: WorkspaceNodeId name => Iso' (PathFromRoot name) WorkspaceId
workspaceId = iso from' to'
  where
    from' (PathFromRoot names) = intercalate "." . fmap (^. workspaceNodeId) $ names
    to' = maybe mempty (PathFromRoot . fmap (^. from workspaceNodeId)) . split
    split :: WorkspaceId -> Maybe [String]
    split = P.parseMaybe sepByDot
    sepByDot :: P.Parsec Void String [String]
    sepByDot = P.some (P.noneOf (Identity '.')) `P.sepBy` P.single '.' <* P.eof

toTreeSelectWorkspaces :: WorkspaceNodeId name => Workspaces name -> Forest WorkspaceId
toTreeSelectWorkspaces = view branches . fmap (^. #name . workspaceNodeId) . view #workspaces

workspacePaths :: Tree (Workspace name) -> [(Name name, PathToRoot name)]
workspacePaths = go (PathToRoot []) . view branches
  where
    go (PathToRoot toRoot) ws = do
        Node w ws' <- ws
        let n = w ^. #name
            toRoot' = PathToRoot (n : toRoot)
        (n, toRoot') : go toRoot' ws'

findSiblings ::
    WorkspaceNodeId name =>
    Ord name =>
    Workspaces name ->
    WorkspaceId ->
    Set WorkspaceId
findSiblings ws wsId = Set.delete wsId . maybe mempty Set.fromList $ do
    parentPath <- wsId ^. from workspaceId . parent
    pure $
        ws
            ^.. ix parentPath
                . branches
                . folded
                . root
                . #name
                . to (\n -> parentPath <> PathFromRoot [n])
                . workspaceId

siblingsWithCurrentWorkspaceAsFocus ::
    WorkspaceNodeId name =>
    Ord name =>
    Workspaces name ->
    WindowSet ->
    WorkspaceId ->
    PL.PointedList WorkspaceId
siblingsWithCurrentWorkspaceAsFocus workspaces_ wset currentWorkspace =
    focusCurrentWorkspace
        . foldr PL.insert (PL.singleton currentWorkspace)
        . filter (`Set.member` workspacesWithWindows)
        . Set.toAscList
        $ findSiblings workspaces_ currentWorkspace
  where
    focusCurrentWorkspace = PL.next
    hasWindows = isJust . W.stack
    workspacesWithWindows =
        Set.fromList . fmap W.tag . filter hasWindows $ W.workspaces wset

addNewWorkspaceIfNotPresent ::
    WorkspaceNodeId name =>
    Ord name =>
    WorkspaceId ->
    Workspaces name ->
    Workspaces name
addNewWorkspaceIfNotPresent newWorkspace =
    let newWorkspacePath@(PathFromRoot ps) = newWorkspace ^. from workspaceId
        newWsNodeId = fromMaybe (WsId newWorkspace) $ viaNonEmpty last ps
        createNewEmptyWorkspaceNode = pure $ Node (Workspace newWsNodeId Nothing) []
     in at newWorkspacePath %~ maybe createNewEmptyWorkspaceNode pure

deleteWorkspaceIfPresent ::
    WorkspaceNodeId name =>
    Ord name =>
    WorkspaceId ->
    Workspaces name ->
    Workspaces name
deleteWorkspaceIfPresent workspace =
    let workspacePath = workspace ^. from workspaceId
     in at workspacePath .~ Nothing

buildTreeFromWorkspaces ::
    [WorkspaceId] ->
    Forest String
buildTreeFromWorkspaces =
    toTreeSelectWorkspaces . foldr addNewWorkspaceIfNotPresent (mkWorkspaces @WorkspaceId)

myTreeselectWorkspace ::
    TreeSelect.TSConfig WorkspaceId ->
    (WorkspaceId -> WindowSet -> WindowSet) ->
    X ()
myTreeselectWorkspace c f = do
    wsTree <- gets (buildTreeFromWorkspaces . fmap W.tag . W.workspaces . windowset)
    TreeSelect.treeselectWorkspace c wsTree f
