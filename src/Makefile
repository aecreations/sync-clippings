# Makefile for Sync Clippings helper app redistributables

DIST_DIR = ../dist/syncClippings
NSI_DIR = ./nsi

default:
	pyinstaller --distpath ../dist --icon program.ico syncClippings.py
	cp -v ../LICENSE.txt $(DIST_DIR)
	cp -v ../CREDITS.txt $(DIST_DIR)
	cd $(DIST_DIR); zip -r syncClippings.zip *
	cp -v $(DIST_DIR)/syncClippings.zip $(NSI_DIR)

mac:
	pyinstaller --distpath ../dist syncClippings.py
	cp -v ../LICENSE.txt $(DIST_DIR)
	cd $(DIST_DIR); zip -r syncClippings.zip *

clean:
	rm -f *~
	rm -rf build
	rm syncClippings.spec
	rm -f $(NSI_DIR)/syncClippings.zip
	rm -f $(NSI_DIR)/*.exe
	cd ..; rm -rf dist

# END Makefile
