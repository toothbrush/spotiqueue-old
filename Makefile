spotiqueue.xml: Spotiqueue.app.zip Spotiqueue/Spotiqueue-Info.plist write-xmlcast.sh
	@echo "Making spotiqueue.xml..."
	./write-xmlcast.sh

Spotiqueue.app.zip: Spotiqueue.app
	ditto -c -k --sequesterRsrc --keepParent $< $@
