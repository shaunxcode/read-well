styles = document.styleSheets[0]

class Comment
    focus: ->
        @commentsWrapper.focus()
        
    constructor: (@line) -> 
        
        @commentsWrapper = $("<div />")
            .addClass("comment")
            .appendTo("#comments")
            .hallo
                plugins:
                    halloformat: {}
                    halloblock: {}
                
        styles.insertRule ".line#{@line} { height: 1.25em; }", styles.rules.length
        
        rule = styles.rules[styles.rules.length - 1]       
        
        @commentsWrapper.on "keyup", => 
            rule.style.height = "#{@commentsWrapper.outerHeight()}px"
        
        @commentsWrapper.trigger "keyup"
        
code = CodeMirror document.getElementById("code"),
    lineNumbers: true

commentStack = []

$comments = $("#comments").on "scroll", ->
    code.scrollTo null, $comments.scrollTop()

oldLineCount = false   
code.on "change", ->
    newLineCount = code.lineCount() 
    if newLineCount isnt oldLineCount
        oldLineCount = newLineCount        
        for l in [0..newLineCount - 1]
            code.addLineClass l, "wrap", "line#{l}"
        
code.on "gutterClick", (cm, line, event) ->    
    if not commentStack[line]
        for l in [commentStack.length..line]
            commentStack[line] = new Comment l
    commentStack[line].focus()

code.on "focus", -> 
    code.setValue code.getValue()

code.on "scroll", -> 
    $comments.scrollTop code.getScrollInfo().top
    
code.setValue "this is some words and that\nand some more words\nand\nmore\nlines"
$code = $("#code");
$scroller = $(".CodeMirror, .CodeMirror-scroll", $code)
$win = $(window).on "resize", -> 
    $comments.css height: $win.innerHeight()
    $scroller.css height: $win.innerHeight()
    $scroller.css width: $win.innerWidth() - $comments.outerWidth() - 5
    
$ -> $win.trigger "resize"