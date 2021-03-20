{-# LANGUAGE DataKinds, TypeOperators #-}
import Control.Concurrent
import Network.HTTP.Client hiding (Proxy)
import Network.Wai.Handler.Warp
import Nix
import Servant
import Servant.Client
import Servant.Nix

-- returns Nix expressions received as input
type IdAPI = ReqBody '[Nix] NExpr :> Post '[Nix] NExpr

api :: Proxy IdAPI
api = Proxy

server :: Server IdAPI
server = pure

postExpr :: NExpr -> ClientM NExpr
postExpr = client api

main :: IO ()
main = do
  mgr <- newManager defaultManagerSettings
  tid <- forkIO $ run 8080 (serve api server)
  threadDelay 500000
  runClientM (postExpr testExpr) (env mgr) >>= \res -> do
    killThread tid
    case res of
      Left err   -> error $ "Problem: " ++ show err
      Right expr -> putStrLn "Roundtrip successful!" >> print expr

  where testExpr = mkList [ mkInt n | n <- [1..10] ]
        env m = mkClientEnv m url
        url   = BaseUrl Http "localhost" 8080 ""
