{-# LANGUAGE MultiParamTypeClasses, OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances, TypeSynonymInstances #-}
module Servant.Nix where

import Data.Text (Text)
import Network.HTTP.Media ((//))
import Nix
import Servant.API.ContentTypes

import qualified Data.ByteString.Lazy    as LBS
import qualified Data.Text.Lazy          as T
import qualified Data.Text.Lazy.Encoding as T

-- | UTF-8 text representing a Nix expression
data Nix

instance Accept Nix where
  contentType _ = "text" // "nix"

-- | 'NExpr' and 'NExprLoc's can be used as request
--   bodies in servant API types.
instance FromNix a => MimeUnrender Nix a where
  mimeUnrender _ = parseAsNix

instance MimeRender Nix NExpr where
  mimeRender _ = T.encodeUtf8 . T.pack . show . prettyNix

-- | Types that can be parsed out of the text of a Nix
--   expression, i.e 'NExpr' and 'NExprLoc'.
class FromNix a where
  fromNixText :: Text -> Result a

instance FromNix NExpr where
  fromNixText = parseNixText

instance FromNix NExprLoc where
  fromNixText = parseNixTextLoc

parseAsNix :: FromNix a => LBS.ByteString -> Either String a
parseAsNix lbs = case fromNixText (T.toStrict $ T.decodeUtf8 lbs) of
  Failure doc -> Left (show doc)
  Success a   -> pure a
