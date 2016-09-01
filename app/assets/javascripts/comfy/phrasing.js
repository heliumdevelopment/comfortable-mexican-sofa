var editor = (function() {

	// Editor elements
	var headerField, contentField, cleanSlate, lastType, currentNodeList, savedSelection;

	// Editor Bubble elements
	var textOptions, optionsBox, boldButton, italicButton, quoteButton, urlButton, urlInput;


	function init() {
		if ($('#zenpenbubble').length){
			lastRange = 0;
			bindElements();

			// Set cursor position
			var range = document.createRange();
			var selection = window.getSelection();
			// range.setStart(headerField, 1);
			selection.removeAllRanges();
			selection.addRange(range);

			createEventBindings();
		}
	}

	function createEventBindings( on ) {

		// Key up bindings
		document.onkeyup = checkTextHighlighting;

		// Mouse bindings
		document.onmousedown = checkTextHighlighting;
		document.onmouseup = function( event ) {

			setTimeout( function() {
				checkTextHighlighting( event );
			}, 1);
		};

		// Window bindings
		window.addEventListener( 'resize', function( event ) {
			updateBubblePosition();
		});

		// Scroll bindings. We limit the events, to free the ui
		// thread and prevent stuttering. See:
		// http://ejohn.org/blog/learning-from-twitter
		var scrollEnabled = true;
		document.body.addEventListener( 'scroll', function() {

			if ( !scrollEnabled ) {
				return;
			}

			scrollEnabled = true;

			updateBubblePosition();

			return setTimeout((function() {
				scrollEnabled = true;
			}), 250);
		});
	}

	function bindElements() {

		contentField = document.querySelector( '.content' );
		textOptions = document.querySelector( '.text-options' );

		optionsBox = textOptions.querySelector( '.options' );

		boldButton = textOptions.querySelector( '.bold' );
		boldButton.onclick = onBoldClick;

		italicButton = textOptions.querySelector( '.italic' );
		italicButton.onclick = onItalicClick;

		// quoteButton = textOptions.querySelector( '.quote' );
		// quoteButton.onclick = onQuoteClick;

		urlButton = textOptions.querySelector( '.url' );
		urlButton.onmousedown = onUrlClick;

		urlInput = textOptions.querySelector( '.url-input' );
		urlInput.onblur = onUrlInputBlur;
		urlInput.onkeydown = onUrlInputKeyDown;
	}

	function checkTextHighlighting( event ) {

		var selection = window.getSelection();

		if (event.target.className === "url-input" || (typeof event.target.classList !== 'undefined' && event.target.classList.contains("url"))) {
			currentNodeList = findNodes( selection.focusNode );
			updateBubbleStates();
			return;
		}

		if (event.target.parentNode.classList != null){
			if (event.target.parentNode.classList.contains("ui-inputs")){
				currentNodeList = findNodes( selection.focusNode );
				updateBubbleStates();
				return;
			}
		}

		// Check selections exist
		if ( selection.isCollapsed === true && lastType === false ) {
			onSelectorBlur();
		}

		// Text is selected
		if ( selection.isCollapsed === false ) {

			currentNodeList = findNodes( selection.focusNode );
			// Find if highlighting is in the editable area
			if (isContentEditable(selection.focusNode) == true) {
				updateBubbleStates();
				updateBubblePosition();

				// Show the ui bubble
				textOptions.className = "text-options active";
			}
		}

		lastType = selection.isCollapsed;
	}

	function updateBubblePosition() {
		var selection = window.getSelection();
		var range = selection.getRangeAt(0);
		var boundary = range.getBoundingClientRect();

		textOptions.style.top = boundary.top - 5 + window.pageYOffset + "px";
		textOptions.style.left = (boundary.left + boundary.right)/2 + "px";
	}

	function updateBubbleStates() {

		// It would be possible to use classList here, but I feel that the
		// browser support isn't quite there, and this functionality doesn't
		// warrent a shim.

		if ( hasNode( currentNodeList, 'B') ) {
			boldButton.className = "bold active"
		} else {
			boldButton.className = "bold"
		}

		if ( hasNode( currentNodeList, 'I') ) {
			italicButton.className = "italic active"
		} else {
			italicButton.className = "italic"
		}

		// if ( hasNode( currentNodeList, 'BLOCKQUOTE') ) {
		// 	quoteButton.className = "quote active"
		// } else {
		// 	quoteButton.className = "quote"
		// }

		if ( hasNode( currentNodeList, 'A') ) {
			urlButton.className = "url useicons active"
		} else {
			urlButton.className = "url useicons"
		}
	}

	function onSelectorBlur() {

		textOptions.className = "text-options fade";
		setTimeout( function() {

			if (textOptions.className == "text-options fade") {

				textOptions.className = "text-options";
				textOptions.style.top = '-999px';
				textOptions.style.left = '-999px';
			}
		}, 260 )
	}

	function findNodes( element ) {

		var nodeNames = {};

		while ( element.parentNode ) {

			nodeNames[element.nodeName] = true;
			element = element.parentNode;

			if ( element.nodeName === 'A' ) {
				nodeNames.url = element.getAttribute("href");
			}
		}

		return nodeNames;
	}

	function isContentEditable(element){
		//if any of its parents has the class of 'phrasable' go hooray
		while ( element.parentNode ) {
			if (element.className !== undefined){
				if (element.className.indexOf("phrasable_on")>=0){
					return true;
				}
			}
			element = element.parentNode;
		}
		return false;
	}

	function hasNode( nodeList, name ) {
		return !!nodeList[ name ];
	}


	function onBoldClick() {
		document.execCommand( 'bold', false );
	}

	function onItalicClick() {
		document.execCommand( 'italic', false );
	}

	// function onQuoteClick() {

	// 	var nodeNames = findNodes( window.getSelection().focusNode );

	// 	if ( hasNode( nodeNames, 'BLOCKQUOTE' ) ) {
	// 		document.execCommand( 'formatBlock', false, 'p' );
	// 		document.execCommand( 'outdent' );
	// 	} else {
	// 		document.execCommand( 'formatBlock', false, 'blockquote' );
	// 	}
	// }

	function onUrlClick() {

		if ( optionsBox.className == 'options' ) {

			optionsBox.className = 'options url-mode';

			// Set timeout here to debounce the focus action
			setTimeout( function() {

				var nodeNames = findNodes( window.getSelection().focusNode );

				if ( hasNode( nodeNames , "A" ) ) {
					urlInput.value = nodeNames.url;
				} else {
					// Symbolize text turning into a link, which is temporary, and will never be seen.
					document.execCommand( 'createLink', false, '/' );
				}

				// Since typing in the input box kills the highlighted text we need
				// to save this selection, to add the url link if it is provided.
				lastSelection = window.getSelection().getRangeAt(0);
				lastType = false;

				urlInput.focus();

			}, 100);

		} else {

			optionsBox.className = 'options';
		}
	}

	function onUrlInputKeyDown( event ) {

		if ( event.keyCode === 13 ) {
			event.preventDefault();
			applyURL( urlInput.value );
			urlInput.blur();
		}
	}

	function onUrlInputBlur( event ) {

		optionsBox.className = 'options';
		applyURL( urlInput.value );
		urlInput.value = '';

		currentNodeList = findNodes( window.getSelection().focusNode );
		updateBubbleStates();
	}

	function applyURL( url ) {

		rehighlightLastSelection();

		// Unlink any current links
		document.execCommand( 'unlink', false );
		if (url !== "") {
			document.execCommand( 'createLink', false, url );
		}
	}

	function rehighlightLastSelection() {

		window.getSelection().addRange( lastSelection );
	}

	return {
		init: init
	}

})();

var phrasing_setup = function(){
  // Initialize the editing bubble
  editor.init();

  // Making sure to send csrf token from layout file.
  $(document).ajaxSend(function(e, xhr, options) {
    var token = $("meta[name='csrf-token']").attr("content");
    xhr.setRequestHeader("X-CSRF-Token", token);
  });

  // Hash size function
  Object.size = function(obj){
    var size = 0, key;
    for (key in obj) { if (obj.hasOwnProperty(key)) size++; }
    return size;
  };

  // Trigger AJAX on textchange
  var trigger_binded_events_for_phrasable_class = 1;
  var timer = {}
  var timer_status = {}

  $('.phrasable').on('DOMNodeInserted DOMNodeRemoved DOMCharacterDataModified', function(e){

    $('#phrasing-edit-mode-bubble #phrasing-saved-status-headline p').text("Saving")
    $('#phrasing-saved-status-indicator-circle').css('background-color', 'orange')

    if (trigger_binded_events_for_phrasable_class == 1){

      var record = this;

      clearTimeout(timer[$(record).data("url")]);
      timer_status[$(record).data("url")] = 0;

      timer[$(record).data("url")] = setTimeout(function(){
        savePhraseViaAjax(record);
        delete timer_status[$(record).data("url")]
      },500)
      timer_status[$(record).data("url")] = 1;
    }

  });

  // AJAX Request
  function savePhraseViaAjax(record){

    var url = $(record).data("url");

    var content = record.innerHTML;

    if(content.length == 0){
      content= "Empty"
    }

    $.ajax({
      type: "PUT",
      url: url,
      data: { new_value: content },
      success: function(e){
        trigger_binded_events_for_phrasable_class = 0;
        if(content == "Empty"){
          $('span.phrasable[data-url="'+ url +'"]').html(content)
        }else{
          $('span.phrasable[data-url="'+ url +'"]').not(record).html(content)
        }
        trigger_binded_events_for_phrasable_class = 1;

        if (Object.size(timer_status) == 0){
          $('#phrasing-edit-mode-bubble #phrasing-saved-status-headline p').text("Saved")
          $('#phrasing-saved-status-indicator-circle').css('background-color', '#56AE45')
        }
      },
      error: function(e){
        $('#phrasing-edit-mode-bubble #phrasing-saved-status-headline p').text("Error")
        $('#phrasing-saved-status-indicator-circle').css('background-color', 'red')
      }
    });
  }

  // Edit Mode On/Off Button
  $('#edit-mode-onoffswitch').on('change', function(){
    if(this.checked){
      $('.phrasable').addClass("phrasable_on").attr("contenteditable", "true");
      $.cookie("editing_mode", "true");
    }
    else{
      $('.phrasable').removeClass("phrasable_on").attr("contenteditable", "false");
      $.cookie("editing_mode", "false");
    }
  });

  if($.cookie("editing_mode") == null){
    $.cookie("editing_mode", "true");
    $('#edit-mode-onoffswitch').prop('checked', true)
  }
  else if($.cookie("editing_mode") == "true"){
    $('#edit-mode-onoffswitch').prop('checked', true)
  }else{
    $('#edit-mode-onoffswitch').prop('checked', false)
  }

};
