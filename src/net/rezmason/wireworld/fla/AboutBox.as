brianCredit.addEventListener(MouseEvent.CLICK, clickBrian);
owenMooreCredit.addEventListener(MouseEvent.CLICK, clickOwenMoore);
sachsCredit.addEventListener(MouseEvent.CLICK, clickSachs);
tdsiMention.addEventListener(MouseEvent.CLICK, clickTDSI);
ccLink.addEventListener(MouseEvent.CLICK, clickCC);
gpLink.addEventListener(MouseEvent.CLICK, clickGP);

function clickBrian(event:MouseEvent):void {
	navigateToURL(new URLRequest("http://llk.media.mit.edu/projects/emergence/"), "_blank");
}

function clickOwenMoore(event:MouseEvent):void {
	navigateToURL(new URLRequest("http://www.quinapalus.com/wi-index.html"), "_blank");
}

function clickSachs(event:MouseEvent):void {
	navigateToURL(new URLRequest("mailto:Jeremy Sachs <jeremysachs@rezmason.net>"), "_blank");
}

function clickTDSI(event:MouseEvent):void {
	navigateToURL(new URLRequest("http://apparat.googlecode.com/"), "_blank");
}

function clickCC(event:MouseEvent):void {
	navigateToURL(new URLRequest("http://creativecommons.org/licenses/by-nc/3.0/us/"), "_blank");
}

function clickGP(event:MouseEvent):void {
	navigateToURL(new URLRequest("http://code.google.com/p/wireworldas3/"), "_blank");
}

