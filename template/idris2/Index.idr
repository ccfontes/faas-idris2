module Index

import Function.Handler

readLines : String -> IO String
readLines acc = do
  line <- getLine
  case line of
    "" => pure acc
    _  => readLines (acc ++ line)

main : IO ()
main = do
  input <- readLines ""
  let output = Handler.handler input
  putStrLn output
