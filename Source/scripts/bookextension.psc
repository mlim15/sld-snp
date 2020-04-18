ScriptName BookExtension Hidden

Function SetRead(Book akBook, Bool isAlreadyRead) global native
    
; Set read with fallback to renaming if the dll is not loaded
Function SetReadWFB(Book b, Bool isAlreadyRead) global
    ; BookExtension is not ported to SSE.
    if (SKSE.GetPluginVersion("BookExtension") != -1)
        SetRead(b, isAlreadyRead)
    endif
endfunction