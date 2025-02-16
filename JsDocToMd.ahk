
class JsDocToMd {
    static Call(Path?, Text?) {
        if IsSet(Path)
            Text := FileRead(Path)
        else if !IsSet(Text)
            Text := A_Clipboard
        if !RegExMatch(Text, 's)/\*\*(.+?)\*/', &MatchJsdoc) {
            throw Error('JSdoc text not found.', -1)
        }
        Items := []
        Str := ''
        while RegExMatch(Text, 'sm)^ +\* +(?<body>(?<tag>@[a-zA-Z0-9_]+).+?)(?= \* @)', &MatchTag, Pos ?? 1) {
            Items.Push(MatchTag)
            Pos := MatchTag.Pos + MatchTag.Len
        }
        for MatchTag in Items {
            ItemText := RegExReplace(MatchTag['body'], '\s+\*\s+(?=[^-\s])', ' ')
            switch MatchTag['tag'], 0 {
                case '@param':
                    Str .= '`n' Trim(this.HandleParam(ItemText), '`r`n`s`t')
                case '@description':
                    Str .= '`n' Trim(this.HandleDescription(ItemText), '`r`n`s`t')
            }
        }
        return Str
    }

    static HandleParam(Text) {
        return RegExReplace(RegExReplace(Text, '^@param', '-'), ' +\*( +)(?=-)', '$1')
    }
    static HandleDescription(Text) {
        return RegExReplace(RegExReplace(Text, '^@description(?: - )?', ''), ' +\* ( *)(?=-)', '$1')
    }
}


if A_LineFIle == A_ScriptFullPath {
    A_Clipboard := JsDocToMd()
    msgbox('done')
}