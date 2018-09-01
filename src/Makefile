# Makefile for Sync Clippings helper app

DIST_DIR = ../dist/syncClippings

default:
	pyinstaller --distpath ../dist --icon program.ico syncClippings.py
	cp -v syncClippings.ini $(DIST_DIR)
	cd $(DIST_DIR); zip syncClippings.zip *
	cp $(DIST_DIR)/syncClippings.zip .

clean:
	rm -f *~
	rm -rf build
	rm syncClippings.spec
	rm syncClippings.zip
	cd ..; rm -rf dist

# END Makefile
