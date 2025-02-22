/*
    v1.00.01
*/

class DocsBuilder {

    static Call(PathInput, PathOutForum, PathOutReadme) {
        this.MakeForumPost(PathInput, PathOutForum)
        this.MakeReadme(PathInput, PathOutReadme)
    }

    static MakeForumPost(PathInput, PathOutForum) {
        Str := RegExReplace(FileRead(PathInput), '\R', '`n')
        ConvertToForum.ExtractCode(&Str, &CodeBlocks, &InlineCode)
        ConvertToForum.ConvertUrl(&Str)
        ConvertToForum.ConvertBold(&Str)
        ConvertToForum.ConvertItalics(&Str)
        ConvertToForum.ExtractList(&Str, &Lists)
        ConvertToForum.ProcessContent(&Str, Lists)
        ConvertToForum.ReplaceCode(&Str, CodeBlocks, InlineCode)
        ConvertToForum.AddChangelog(&Str)
        f := FileOpen(PathOutForum, 'w')
        f.Write(Str)
        f.Close()
    }

    static MakeReadme(PathInput, PathOutReadme) {

    }
}


class ConvertToForum {
    static ObjReplacementChar := Chr(0xFFFC)

    static ConvertInlineCode(&Str) {
        Str := RegExReplace(Str, '``([^``]+)``', '[c]$1[/c]')
    }
    
    static ConvertBold(&Str) {
        Str := RegExReplace(Str, '\*\*(.+?)\*\*', '[b]$1[/b]')
    }

    static ConvertItalics(&Str) {
        Str := RegExReplace(Str, '\*(.+?)\*', '[i]$1[/i]')
    }
    
    static ConvertCodeBlock(&Str) {
        Str := RegExReplace(Str, '``````(.*?)``````', '[code]$1[/code]')
    }
    
    static ConvertUrl(&Str) {
        while RegExMatch(Str, '(?<!\])(?<!\))https?://\S+', &MatchUrl) {
            Str := StrReplace(Str, MatchUrl[0], '[url]' MatchUrl[0] '[/url]')
        outputdebug('`n`n' str)
        }
        while RegExMatch(Str, '\[(.+?)\]\((https?://.+?)\)', &MatchUrl) {
            Str := StrReplace(Str, MatchUrl[0], '[url=' MatchUrl[2] ']' MatchUrl[1] '[/url]')
        }
    }

    static ConvertColor(&Str) {
        while RegExMatch(Str, 's)<span style="color:([^"]+)">(.+?)</span>', &MatchColor)
            Str := StrReplace(Str, MatchColor[0], '[color=' MatchColor[1] ']' MatchColor[2] '[/color]')
    }

    static ConvertSize(&Str) {
        while RegExMatch(Str, 's)<span style="font-size:(\d+)">(.+?)</span>', &MatchSize)
            Str := StrReplace(Str, MatchSize[0], '[size=' this.RoundSize(Number(MatchSize[1])) ']' MatchSize[2] '[/size]')
    }

    static ConvertParam(&StrList) {
        global AhkForum
        StrList := Trim(StrList, '`n')
        while Pos := RegExMatch(StrList, 's)(?:^|\R)\K-\s+(?<type>\{[^}]+\})\s+(?<var>\S+)\s+(?<description>.+?)(?=\R-|$)', &MatchParam, Pos ?? 1) {
            StrList := StrReplace(StrList, MatchParam[0],
                '[*]' AhkForum.ParamSize AhkForum.ParamTypeColor '[b]' MatchParam['type']
                '[/color] ' MatchParam['var'] '[/b] ' MatchParam['description'] '[/size]'
            )
        }
        StrList := '[list]' StrList '[/list]`n'
    }

    static ConvertTagWithType(&StrList) {
        global AhkForum
        StrList := Trim(StrList, '`n')
        while Pos := RegExMatch(StrList, 's)(?:^|\R)\K-\s+(?<type>\{[^}]+\})\s+(?<description>.+?)(?=\R-|$)', &MatchParam, Pos ?? 1) {
            StrList := StrReplace(StrList, MatchParam[0],
                '[*]' AhkForum.ParamSize AhkForum.ParamTypeColor '[b]' MatchParam['type']
                '[/color][/b] ' MatchParam['description'] '[/size]'
            )
        }
        StrList := '[list]' StrList '[/list]`n'
    }

    static ConvertList(StrList) {
        if RegExMatch(StrList, 'm)^- \{[^}]+\}\s+\S+ - ')
            this.ConvertParam(&StrList)
        else if RegExMatch(StrList, 'm)^- \{[^}]+\}\s+- ')
            this.ConvertTagWithType(&StrList)
        else
            this.ProcessList(&StrList)
        return StrList
    }
    static ProcessList(&StrList) {
        global AhkForum
        StrList := Trim(StrList, '`n')
        while Pos := RegExMatch(StrList, 'm)^(\s*)-\s+(.+)', &MatchListContent, Pos ?? 1) {
            if MatchListContent.Len[1] {
                StrList := StrReplace(StrList, MatchListContent[0]
                    , (A_Index == 1 ? '[list]' : '')
                    '[*][indent=' MatchListContent.Len[1] ']'
                    AhkForum.TextColor AhkForum.TextSize MatchListContent[2] '[/size][/color][/indent]'
                )
            } else {
                StrList := StrReplace(StrList, MatchListContent[0]
                    , (A_Index == 1 ? '[list]' : '') '[*]'
                    AhkForum.TextColor AhkForum.TextSize MatchListContent[2] '[/size][/color]'
                )
            }
        }
        StrList .= '[/list]`n'
    }
    
    static AddCode(&Str, Path) {
        Str .= (
            '[code]`n'
            ; Standardize newlines, remove trailing whitespace, pad start and end with a newline.
            RegExReplace(RegExReplace(RegExReplace(RegExReplace(FileRead(Path)
            , '\R', '`n'), 'm)\s+$', ''), '^\n*(?=[^\r\n])', '`n'), '(?<=[^\r\n])\n*$', '`n')
            '`n[/code]`n`n'
        )
    }

    static AddChangelog(&Str) {
        global Changelog, AhkForum
        ConvertToForum.ConvertInlineCode(&Changelog)
        ConvertToForum.ConvertUrl(&Changelog)
        ConvertToForum.ConvertBold(&Changelog)
        ConvertToForum.ConvertItalics(&Changelog)
        ConvertToForum.ExtractList(&Changelog, &Lists)
        Str .= AhkForum.Header2Color AhkForum.Header2Size 'Changelog[/size][/color]`n'
        Pos := 1
        while RegExMatch(Changelog, '@@@List:(\d+)@@@', &MatchList, Pos ?? 1) {
            Str .= (
                AhkForum.ChangelogDateColor AhkForum.ChangelogDateSize '[b]'
                SubStr(Changelog, Pos, MatchList.Pos - Pos - 1) '[/b][/size][/color]`n'
                this.ConvertList(Lists[MatchList[1]][0]) '`n'
            )
            Pos := MatchList.Pos + MatchList.Len + 1
        }
    }

    static AddLink(&Str) {
        global AhkForum, Github
        outputdebug(str)
        if !RegExMatch(Str, 'm)^@@@Link@@@', &MatchLink)
            throw Error('Link section not found', -1)
        Str := StrReplace(Str, MatchLink[0], AhkForum.Header3Color AhkForum.Header3Size 'Github link[/size][/color]`n' Github.Link '[/size][/color]')
    }

    static ExtractCode(&Str, &OutCodeBlocks, &OutInlineCode) {
        OutCodeBlocks := []
        while RegExMatch(Str, 's)``````(.+?)``````', &MatchCode) {
            Str := StrReplace(Str, MatchCode[0], '@@@CodeBlock:' A_Index '@@@')
            OutCodeBlocks.Push(MatchCode)
        }
        OutInlineCode := []
        while RegExMatch(Str, '``([^``]+)``', &MatchInlineCode) {
            Str := StrReplace(Str, MatchInlineCode[0], '@@@InlineCode:' A_Index '@@@')
            OutInlineCode.Push(MatchInlineCode)
        }
    }

    static ReplaceCode(&Str, CodeBlocks?, InlineCode?) {
        if IsSet(CodeBlocks) {
            for Code in CodeBlocks
                Str := StrReplace(Str, '@@@CodeBlock:' A_Index '@@@', '[code]`n' Code[1] '`n[/code]')
        }
        if IsSet(InlineCode) {
            for Code in InlineCode
                Str := StrReplace(Str, '@@@InlineCode:' A_Index '@@@', '[c]' Code[1] '[/c]')
        }
    }
    
    static ProcessContent(&Str, Lists) {
        global AhkForum
        FlagFile := false
        Split := StrSplit(Str, '`n#')
        Str := ''
        for S in Split {
            if !S
                continue
            OutputDebug('`n`nLoop ' A_Index '`n' Str)
            if !RegExMatch(S, '^(#*)\s+(.+)\R([\w\W]*)', &MatchContent)
                throw Error('The pattern didn`'t match.', -1)
            ; Add header, file headers are handled separately.
            if RegExMatch(MatchContent[2], '\.[a-zA-Z0-9]{2,4}$') {
                Str .= AhkForum.FileNameColor AhkForum.FileNameSize '[b]' MatchContent[2] '[/b][/size][/color]`n'
                ; If the header is a file name, the flag is set to be referened later in the loop.
                FlagFile := true
            } else {
                Str .= (
                    AhkForum.Header%(MatchContent.Len[1] + 1)%Color
                    AhkForum.Header%(MatchContent.Len[1] + 1)%Size '[b]'
                    Trim(MatchContent[2], '`n') '[/b][/size][/color]`n'
                )
            }
            ; Split the body into its paragraphs.
            BodySplit := StrSplit(MatchContent[3], '`n`n', '`n')
            for B in BodySplit {
                ; If the item is only whitespace, skip it.
                if !RegExMatch(B, '\S')
                    continue
                ; Handle the link text.
                if RegExMatch(B, 'm)^@@@Link@@@', &MatchLink) {
                    Str .= StrReplace(B, MatchLink[0]
                    , AhkForum.Header2Color AhkForum.Header2Size
                    '[b]Github link[/b][/size][/color]`n'
                    AhkForum.TextSize Github.Link '[/size]'
                    ) '`n`n'
                    continue
                }
                ; Replace lists using forum post syntax. Lists are extracted first because the size and
                ; color tags have a weird interaction with the list tags, so it's necessary to end any
                ; preceding size and color tags prior to beginning the list, then re-start the size and
                ; color tags after the list is complete.
                StrReplace(B, '@@@List:', , , &Count)
                if Count {
                    Pos := 1
                    loop Count {
                        PosList := InStr(B, '@@@List:', , Pos)
                        if PosList !== Pos {
                            Str .= (
                                AhkForum.TextColor AhkForum.TextSize
                                Trim(SubStr(B, Pos, PosList - Pos), '`n')
                                '[/size][/color]`n'
                            )
                        }
                        RegExMatch(B, '@@@List:(\d+)@@@', &MatchList, Pos)
                        Str .= this.ConvertList(Lists[MatchList[1]][0]) '`n'
                        if Count == A_Index && RegExMatch(ss := SubStr(B, MatchList.Pos + MatchList.Len), '\S')
                            Str .= AhkForum.TextColor AhkForum.TextSize ss '[/size][/color]`n`n'
                        else
                            Pos := MatchList.Pos + MatchList.Len + 1
                    }
                ; If the paragraph is a block of inline code, it should not have size and color tags.
                ; Currently, it's required that code blocks are separated from other body paragraphs by
                ; two newlines, or else this replaement doesn't work correctly.
                /* @Todo - update so this is nolonger necessary. */
                } else if InStr(B, '@@@CodeBlock:') {
                    Str .= B '`n`n'
                ; All other paragraphs can be wrapped in size and color tags.
                } else {
                    Str .= AhkForum.TextColor AhkForum.TextSize B '[/size][/color]' (FlagFile ? '`n' : '`n`n')
                }
            }
            ; If the header is a file name, put the code in code blocks.
            if FlagFile {
                this.AddCode(&Str, '..\' MatchContent[2])
                FlagFile := false
            }
        }
    }

    static ExtractList(&Str, &OutList?) {
        OutList := []
        while RegExMatch(Str, 'm)(?:^ *-.+\R?)+', &MatchList) {
            Str := StrReplace(Str, MatchList[0], '@@@List:' A_Index '@@@')
            OutList.Push(MatchList)
        }
    }
}


class ConvertToMd {
    static SizeCoefficient := '.12'
    static Call(Str?, Path?) {
        if IsSet(Path)
            Str := FileRead(Path)
        else if !IsSet(Str)
            Str := A_Clipboard, FlagClipboard := 1
        this.ConvertC(&Str)
        this.ConvertUrl(&Str)
        this.ConvertColor(&Str)
        this.ConvertSize(&Str)
        this.ConvertB(&Str)
        if FlagClipboard
            A_Clipboard := Str
        else
            return Str
    }

    static ConvertInlineCode(&Str) {
        Str := RegExReplace(Str, 's)\[c\](.+?)\[/c\]', '``$1``')
    }

    static ConvertBold(&Str) {
        Str := RegExReplace(Str, 's)\[b\]([^\[]+)\[/b\]', '**$1**')
    }

    static ConvertCodeBlock(&Str) {
        Str := RegExReplace(Str, 's)\[code\](.+?)\[/code\]', '``````$1``````')
    }

    static ConvertUrl(&Str) {
        while RegExMatch(Str, '\[url\](.+?)\[/url\]', &MatchUrl) {
            Str := StrReplace(Str, MatchUrl[0], MatchUrl[1])
        }
        while RegExMatch(Str, '\[url=([^\]]+)\](.+?)\[/url\]', &MatchUrl) {
            Str := StrReplace(Str, MatchUrl[0], '[' MatchUrl[1] ']' '(' MatchUrl[2] ')')
        }
    }

    static ConvertColor(&Str) {
        while RegExMatch(Str, 's)\[color=([^\]]+)\](.+?)\[/color\]', &MatchColor)
            Str := StrReplace(Str, MatchColor[0], '<span style="color:' MatchColor[1] '">' MatchColor[2] '</span>')
    }

    static ConvertSize(&Str) {
        while RegExMatch(Str, 's)\[size=([^\]]+)\](.+?)\[/size\]', &MatchSize)
            Str := StrReplace(Str, MatchSize[0], '<span style="font-size:'
            Round(Number(MatchSize[1]) * this.SizeCoefficient, 0) '">'
            MatchSize[2] '</span>')
    }
}
