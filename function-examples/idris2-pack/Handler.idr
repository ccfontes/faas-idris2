module Function.Handler

import Data.HashMap as HashMap
import Dinwiddy.Array as Array
import Data.Vect as Vect

value : Array.Array 2 [1, 3] Int
value = [[1, 2, 3]]

export
handler : String -> String
handler key =
  let hm = HashMap.insert "key" (Vect.index 0 value) HashMap.empty in
  case HashMap.lookup key hm of
    Nothing => "Key not found"
    Just v => "Value for key: " ++ show v
