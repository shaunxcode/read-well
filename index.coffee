$ -> 
	tools = $("<div />").appendTo "body"
	tools.append(
		$("<button />").text "import"
		$("<button />").text "export")
	tools.hide()
	
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
			mergeControl.hide()
			
		remove = false

		input.on 'keydown', (e) -> 
			#TAB
			if e.keyCode is 9
				e.preventDefault()
				start = input.get(0).selectionStart
				chars = input.val()
				input.val chars.substring(0, start) + "\t" + chars.substring(start, chars.length)
				input.get(0).setSelectionRange start + 1, start + 1
			
			#UP
			if e.keyCode is 38 and line.prior
				e.preventDefault()
				start = input.get(0).selectionStart
				line.prior.code.focus()
				line.prior.code.input.get(0).setSelectionRange start, start
			#DOWN
			if e.keyCode is 40 and line.next
				e.preventDefault()
				start = input.get(0).selectionStart
				line.next.code.focus()
				line.next.code.input.get(0).setSelectionRange start, start

			#BACKSPACE
			if e.keyCode is 8 and input.get(0).selectionStart is 0 and line.prior
				if remove or input.val().length
					e.preventDefault()
					line.prior.next = line.next
					line.next.prior = line.prior
					val = input.val()
					if val.replace(/\s+/, '').length
						line.prior.code.val line.prior.code.val() + val

					rowSpannedComment = line.code.prev('.margin[rowspan]')
					if rowSpannedComment.length

						nextComment = $(".margin", line.next.container)
						if nextComment.length
							nextComment.prepend rowSpannedComment.html()
							nextComment.attr "rowspan", nextComment.attr("rowspan") + rowSpannedComment.attr("rowspan") - 1 
						else
							rowSpannedComment.attr "rowspan", parseInt(rowSpannedComment.attr "rowspan") - 1
							line.next.container.prepend rowSpannedComment
						

					row = line.code.parent()
					while not comment?.length
						comment = $(".margin", row)
						if not comment.length then row = row.prev()
					
					if (comment.attr("rowspan") or 1) > 1
						comment.attr "rowspan", parseInt(comment.attr "rowspan") - 1

					line.container.remove()

					line.prior.code.focus()
					caretPos = line.prior.code.val().length - val.length
					line.prior.code.input.get(0).setSelectionRange caretPos, caretPos
					activeLine = line.prior
				else 
					remove = true
					return
					
			#ENTER
			if e.keyCode is 13
				oldNext = line.next
				oldNext.prior = line.next = addLine()
				line.next.next = oldNext
				
				row = line.code.parent()
				while not comment?.length
					comment = $(".margin", row)
					if not comment.length then row = row.prev()
				
				if (comment.attr("rowspan") or 1) > 1
					line.next.comment.remove()
					comment.attr "rowspan", parseInt(comment.attr "rowspan") + 1

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
			true
			
		cell
	
	mergeControl = 	$("<div />")
		.addClass("mergeControl")
		.appendTo("body")
		.hide()
		.text("[merge]")
		.on click: -> 
			#walk back up til we get to activeLine
			cells = []
			row = mergeControl.mergeWithEl.parent()
			while row.length 
				break if not row.length
				cell = $(".margin", row)
				if cell.length
					break if cell.get(0) is activeLine.comment.get(0)
					cells.push cell
				row = row.prev()

			rowSpan = parseInt(activeLine.comment.attr "rowspan") or 1

			content = []
			if cells.length
				for cell in cells
					if cell.html().length
						content.unshift cell.html()
					rowSpan += parseInt(cell.attr "rowspan") or 1
					cell.remove()

			if content.length 
				content.unshift ""

			activeLine.comment
				.attr("rowspan", rowSpan)
				.append content.join "<br />"

			mergeControl.hide()
			activeLine.comment.focus()
			
	mergeControl.reposition = -> 
		mergeControl.css
			left: mergeControl.mergeWithEl.offset().left + 30
			top: mergeControl.mergeWithEl.offset().top
	
	marginCell = (line) ->
		cell = $("<td />").addClass("margin").attr(contentEditable: true)
		cell.on
			mouseenter: (e) ->
				el = $(this)

				return if (not activeLine.comment.parent().get(0)?) or el.parent().get(0).rowIndex < activeLine.comment.parent().get(0).rowIndex 
				if el.is(':empty') and this isnt activeLine.comment.get(0) and activeLine.comment.is(':focus')
					mergeControl.mergeWithEl = el
					mergeControl.show().reposition()
					
			focus: (e) ->	
				mergeControl.hide()
				activeLine = line

			blur: (e) ->
				#mergeControl.hide()
				
			keyup: (e) ->
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

				#clear out annoying dangling br tag
				if e.keyCode is 8 and $(this).text().length is 0
					$(this).html('')
				#UP
				if e.keyCode is 38 and at_start and line.prior
					line.prior.comment.focus()
					activeLine = line.prior
				#DOWN
				if e.keyCode is 40 and at_end and line.next
					line.next.comment.focus()
					activeLine = line.next
				#ENTER/#BACKSPACE
				if (e.keyCode is 13 or e.keyCode is 8) and mergeControl.is(':visible')
					mergeControl.reposition()

		cell
		
	addLine = ->
		line = 
			prior: activeLine
			next: false
			
		line.container = $("<tr />").append(
			line.comment = marginCell line
			line.code = editCell line)

		line.comment.hallo
			plugins: 
				halloformat: {}
				halloblock: {}
				hallojustify: {}

		if activeLine
			activeLine.container.after line.container
		else
			editor.append line.container

		line
 
	#hickity hack
	activeLine = addLine()
	activeLine.comment.html("<h1>YourFileName.here</h1>Some sort of description")
	activeLine.code.focus()

