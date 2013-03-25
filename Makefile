spotiqueue.xml: Spotiqueue.app.zip Spotiqueue/Spotiqueue-Info.plist write-xmlcast.sh
	@echo "Making spotiqueue.xml..."
	./write-xmlcast.sh
	@echo "Now you can use 'make upload'."

Spotiqueue.app.zip: Spotiqueue.app
	ditto -c -k --sequesterRsrc --keepParent $< $@

.PHONY: upload
upload: spotiqueue.xml Spotiqueue.app.zip
	rsync -av --progress spotiqueue.xml Spotiqueue.app.zip nfs:/home/public/files/
