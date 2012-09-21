$ -> 
	editor = $("<table />").appendTo "body"

	activeLine = false
  
	editCell = (line) ->	
		cell = $("<td />").addClass('code').append(input = $("<input />"))
	
		cell.input = input
		
		cell.on 'click', -> cell.focus()
	
		cell.val = (v) -> 
			if v
				input.val v
			else
				input.val()
		
		cell.focus = -> 
			input.focus()
			activeLine = line
	 
		input.on 'keydown', (e) -> if e.keyCode is 9 then e.preventDefault()

		remove = false
		input.on 'keyup', (e) ->	
			#TAB
			if e.keyCode is 9 
				start = input.get(0).selectionStart
				chars = input.val()
				input.val chars.substring(0, start) + "\t" + chars.substring(start, chars.length)
				input.get(0).setSelectionRange start + 1, start + 1
			#UP
			if e.keyCode is 38 and line.prior
				line.prior.code.focus()
			#DOWN
			if e.keyCode is 40 and line.next
				line.next.code.focus()
			#BACKSPACE
			if e.keyCode is 8 and input.get(0).selectionStart is 0 and line.prior
				if remove or input.val().length
					line.prior.next = line.next
					line.next.prior = line.prior
					val = input.val()
					if val.replace(/\s+/, '').length
						line.prior.code.val line.prior.code.val() + val
					line.container.remove()
					line.prior.code.focus()
				else 
					remove = true
					return
				
			#ENTER
			if e.keyCode is 13
				oldNext = line.next
				oldNext.prior = line.next = addLine()
				line.next.next = oldNext
				
				remainingChars = input.val().substring(input.get(0).selectionStart, input.val().length)
				if remainingChars.length
					line.next.code.val remainingChars
					input.val input.val().substring(0, input.get(0).selectionStart)
					line.next.code.input.focus()
					line.next.code.input.get(0).setSelectionRange 0, 0
				else
					curSpace = input.val().match /^\s+/

					if curSpace?.length
						line.next.code.val curSpace[0]
				
					line.next.code.focus()
				
			remove = false
		cell
	
	marginCell = (line) ->
		cell = $("<td />").addClass("margin").attr(contentEditable: true)
		cell.on 'keyup', (e) ->
			range = window.getSelection().getRangeAt(0)
			pre_range = document.createRange()
			pre_range.selectNodeContents(this)
			pre_range.setEnd(range.startContainer, range.startOffset)
			this_text = pre_range.cloneContents()
			at_start = this_text.textContent.length is 0
			post_range = document.createRange()
			post_range.selectNodeContents(this)
			post_range.setStart(range.endContainer, range.endOffset)
			next_text = post_range.cloneContents()
			at_end = next_text.textContent.length is 0

			#UP
			if e.keyCode is 38 and at_start and line.prior
				line.prior.comment.focus()
				activeLine = line.prior
			#DOWN
			if e.keyCode is 40 and at_end and line.next
				line.next.comment.focus()
				activeLine = line.next
		cell
		
	addLine = ->
		line = 
			prior: activeLine
			next: false
			
		line.container = $("<tr />").append(
			line.comment = marginCell line
			line.code = editCell line)
		
		if activeLine
			activeLine.container.after line.container
		else		   
			editor.append line.container

		line
 
	#hickity hack
	title = addLine()
	title.code.input.remove()
	title.comment.html("<h1>YourFileName.here</h1>Some sort of description")
	activeLine = title

	newLine = addLine()
	title.next = newLine
	newLine.code.focus()
