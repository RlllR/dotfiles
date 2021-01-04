-------------------------------------------------------------------------------
-- |
-- Module      : XMonad.Actions.ConditionalKeys -- better as PerLayoutKeys not Generalized?
-- Copyright   : (c)
-- License     : BSD3-style (see LICENSE)
--
-- Mainteiner  : ?
-- Stability   : unstable
-- Portability : unportable
--
-- Define key-bindings on per-workspace or per-layout basis.
--
-------------------------------------------------------------------------------

-- stumbled accross this at http://lpaste.net/annotate/53022
-- couldn't identify author

-- cf similar at https://github.com/ervandew/dotfiles/blob/master/.xmonad/lib/XMonad/Actions/PerLayoutKeys.hs
-- and http://lpste.net/44409/perlayoutkeys?pid=44409&lang_44409=cpp


module XMonad.Actions.ConditionalKeys (
                                -- * Usage
                                -- $usage
                                XCond(..),
                                chooseAction,
                                bindOn
                                ) where

import XMonad
import qualified XMonad.StackSet as W
import Data.List (find)

data XCond = WS | LD
chooseAction :: XCond -> (String->X()) -> X()
chooseAction WS f = withWindowSet (f . W.currentTag)
chooseAction LD f = withWindowSet (f . description . W.layout . W.workspace . W.current)

bindOn :: XCond -> [(String, X())] -> X()
bindOn xc bindings = chooseAction xc $ chooser where
    chooser xc = case find ((xc==).fst) bindings of
        Just (_, action) -> action
        Nothing -> case find ((""==).fst) bindings of
            Just (_, action) -> action
            Nothing -> return ()
