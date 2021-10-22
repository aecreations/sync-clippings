# Makefile for Sync Clippings helper app redistributables

DIST_DIR = ../build/syncClippings
NSI_DIR = ./nsi

default:
	pyinstaller --distpath ../build --icon program.ico syncClippings.py
	cp -v ../LICENSE.txt $(DIST_DIR)
	cp -v ../CREDITS.txt $(DIST_DIR)
	cd $(DIST_DIR); zip -r syncClippings.zip *
	cp -v $(DIST_DIR)/syncClippings.zip $(NSI_DIR)

mac:
	pyinstaller --distpath ../build syncClippings.py
	cp -v ../LICENSE.txt $(DIST_DIR)
	cd $(DIST_DIR); zip -r syncClippings.zip *

clean:
	rm -f *~
	rm -rf build
	rm syncClippings.spec
	rm -f $(NSI_DIR)/syncClippings.zip
	rm -f $(NSI_DIR)/*.exe
	cd ..; rm -rf build

# END Makefile
