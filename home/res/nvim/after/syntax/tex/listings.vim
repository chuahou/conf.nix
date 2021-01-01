" from https://stackoverflow.com/a/21651323/12372506
syn region texZone start="\\begin{lstlisting}" end="\\end{lstlisting}\|%stopzone\>"
syn region texZone start="\\lstinputlisting" end="{\s*[a-zA-Z/.0-9_^]\+\s*}"
syn match texInputFile "\\lstinline\s*\(\[.*\]\)\={.\{-}}" contains=texStatement,texInputCurlies,texInputFileOpt
