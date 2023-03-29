module Function.Handler

import Dinwiddy.Array as Array
import Data.Vect as Vect

%foreign "javascript:lambda: s => require('capital-case').capitalCase(s)"
prim__capitalize : String -> String

capitalize : String -> String
capitalize s = prim__capitalize s

value : Array.Array 2 [1, 3] String
value = [["sato", "satoshi", "sarariman"]]

export
handler : String -> String
handler _ =
  let capitalized = map capitalize (Vect.index 0 value) in
    show capitalized
