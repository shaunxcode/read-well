$ -> 
    editor = $("<table />").appendTo "body"

    activeLine = false
  
    editCell = (line) ->    
        cell = $("<td />").addClass('code').append(input = $("<input />"))
    
        cell.on 'click', -> cell.focus()
    
        cell.focus = -> 
            input.focus()
            activeLine = line
     
        input.on 'keydown', (e) -> if e.keyCode is 9 then e.preventDefault()
        input.on 'keyup', (e) ->    
            #TAB
            if e.keyCode is 9 
                console.log "tab"         
            #UP
            if e.keyCode is 38 and line.prior
                line.prior.code.focus()
            #DOWN
            if e.keyCode is 40 and line.next
                line.next.code.focus()
            #BACKSPACE
            if e.keyCode is 8 and input.val().replace(/\s+/, '').length is 0 and line.prior
                line.container.remove()
                line.prior.code.focus()
            #ENTER
            if e.keyCode is 13
                line.next = addLine().code.focus()
    
        cell
    
    marginCell = ->
        $("<td />").addClass("margin").attr(width: "100", contentEditable: true)
  
    addLine = ->
        line = 
            prior: activeLine
            next: false
            
        line.container = $("<tr />").append(
            line.comment = marginCell()
            line.code = editCell(line))
        
        if activeLine
            activeLine.container.after line.container
        else           
            editor.append line.container

        line
 
    addLine().code.focus()

