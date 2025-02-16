#Include ..\..\DocsBuilder\DocsBuilder.ahk

AhkForum := {
    Link: ''
  , Header2Color: '[color=#800000]'
  , Header3Color: '[color=#800000]'
  , Header2Size: '[size=165]'
  , Header3Size: '[size=150]'
  , TextSize: '[size=125]'
  , TextColor: '[color=#000000]'
  , ParamTypeColor: '[color=#008000]'
  , ParamSize: '[size=112]'
  , ChangelogDateSize: '[size=120]'
  , ChangelogDateColor: '[color=#000000]'
  , ChangelogTextSize: '[size=110]'
  , ChangelogTextColor: '[color=#000000]'
  , FileNameSize: '[size=135]'
  , FileNameColor: '[color=#000000]'
}

Github := {
    Link: ''
}

Changelog := FileRead('Changelog.md')

if A_LineFile == A_ScriptFullPath {
    DocsBuilder.MakeForumPost('README-raw.md', 'AHK-forum-post.txt')
    msgbox('done')
}