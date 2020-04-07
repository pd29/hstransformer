module Main where

-- #region_c import
import           Data.Aeson
import           Data.Aeson.Types
import           Data.List                      ( intercalate )
import           Data.Maybe
import           Data.Foldable
import           Data.Vector                    ( ifoldr )
import           System.FilePath.Glob
import qualified Data.HashMap.Strict           as H
-- #endregion

main = do
    paths <- glob "*.json"
    outs  <- mapM readAndTransform paths
    putStrLn $ intercalate "\n" outs

readAndTransform f = do
    d <- decodeFileStrict f
    return $ transform (expectDecoded f d) ""

transform v prefix = case v of
    Object o -> foldr (\(k, v) a -> a ++ (transform v $ (++) varName $ stripQuotes . show $ k) ++ "\n") "" $ H.toList o
    Array  a -> ifoldr (\k v a -> a ++ transform v (varName ++ show k) ++ "\n") "" a
    String s -> display prefix s
    Number n -> display prefix n
    Bool   b -> display prefix b
  where
    varName = prefix ++ if prefix == "" then "" else "__"
    display prefix s = prefix ++ " = " ++ show s

-- #region_c utils
expect err = fromMaybe (error err)
expectDecoded file = expect $ "can't decode " ++ (show file)
strip what = filter ((/=) what)
stripQuotes = strip '\"'
(|>) a b = b a
-- #endregion