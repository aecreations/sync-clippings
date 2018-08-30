# Makefile for Sync Clippings helper app

DIST_DIR = ../dist/syncClippings

default:
	pyinstaller --distpath ../dist syncClippings.py
	cp -v syncClippings.ini $(DIST_DIR)

clean:
	rm -f *~
	rm -rf build
	rm syncClippings.spec
	cd ..; rm -rf dist

# END Makefile
