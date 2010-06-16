var direction:Number = 1, magnitude:Number = 0;
var styleInitialized:Boolean = false;
var textMask:Shape = new Shape();

addChild(textMask);
textbox.mask = textMask;
textMask.graphics.beginFill(0x0);
textMask.graphics.drawRect(0, 0, textbox.width, textbox.height);
textMask.graphics.endFill();
textMask.x = textbox.x;
textMask.y = textbox.y;
textbox.autoSize = TextFieldAutoSize.LEFT;

upButton.addEventListener(MouseEvent.MOUSE_DOWN, updatePage);
downButton.addEventListener(MouseEvent.MOUSE_DOWN, updatePage);

if (stage) {
	connectToStage();
} else {
	addEventListener(Event.ADDED_TO_STAGE, connectToStage);
}

function connectToStage(event:Event = null):void {
	if (event) {
		removeEventListener(Event.ADDED_TO_STAGE, connectToStage);
	}
	stage.addEventListener(Event.MOUSE_LEAVE, letGo, false, 0, true);
	stage.addEventListener(MouseEvent.MOUSE_UP, letGo, false, 0, true);
}

function updatePage(event:Event):void {
	if ( event.currentTarget == upButton) {
		direction = 1;
	} else {
		direction = -1;
	}
	magnitude = 1;
	addEventListener(Event.ENTER_FRAME, movePage);
	movePage();
}

function letGo(event:Event):void {
	removeEventListener(Event.ENTER_FRAME, movePage);
}

function movePage(event:Event = null):void {
	var n:Number = textbox.y - textMask.y + direction * magnitude;
	if (n < 0 && n > textMask.height - 30 - textbox.height) {
		textbox.y += direction * magnitude;
		if (magnitude < 15) {
			magnitude *= 1.05;
		}
	} else {
		magnitude /= 1.05;
	}
}

function setText(html:String):void {
	html = html.replace(/<title>.*<\/title>/g, "");
	html = html.replace(/sendto/g, "mailto");
	html = html.replace(/ATSYMBOL/g, "@");
	html = html.replace(/[\n\r\t]/g, "");
	html = html.replace(/<\/h1>/g, "</h1>\n");
	html = html.replace(/<\/p>/g, "</p>\n");
	html = html.replace(/<\/ul>/g, "</ul>\n");
	
	if (!styleInitialized) {
		var readMeStyle:StyleSheet = new StyleSheet();
		readMeStyle.setStyle("h1", {fontSize:"20px"});
		readMeStyle.setStyle("body", {fontSize:"14px", lineHeight:"5px", color:"#FFFFFF", fontFamily:"_sans"});
		readMeStyle.setStyle("a", {textDecoration:"underline"});
		readMeStyle.setStyle("li", {fontSize:"12px"});
		textbox.styleSheet = readMeStyle;
		styleInitialized = true;
	}
	
	textbox.htmlText = html;
}