# Makefile for Sync Clippings helper app redistributables

DIST_DIR = ../dist/syncClippings

default:
	pyinstaller --distpath ../dist --icon program.ico syncClippings.py
	cp -v ../LICENSE.txt $(DIST_DIR)
	cp -v ../CREDITS.txt $(DIST_DIR)
	cd $(DIST_DIR); zip syncClippings.zip *
	cp -v $(DIST_DIR)/syncClippings.zip .

clean:
	rm -f *~
	rm -rf build
	rm syncClippings.spec
	rm syncClippings.zip
	rm -f *.exe
	cd ..; rm -rf dist

# END Makefile
