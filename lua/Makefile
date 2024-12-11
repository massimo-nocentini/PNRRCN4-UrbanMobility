
linux:
	clang -O3 -fPIC -Wall -o average average.c -lm
	gcc -O3 -fPIC -Wall -shared -o libluabag.so libluabag.c -L/home/mnocentini/Developer/snapshots/lua/lua-5.4.7/src -llua -lpthread
	
macos:
	clang -O3 -fPIC -Wall -dynamiclib -o libluabag.dylib libluabag.c -llua -pthread
	
install:
	mkdir -p /usr/local/lib/lua/5.4/	# just for ensuring that the dest dir exists
	mkdir -p /usr/local/share/lua/5.4/	# just for ensuring that the dest dir exists
	mv libluabag.so /usr/local/lib/lua/5.4/
	#cp luabag.lua /usr/local/share/lua/5.4/

install-macos:
	mkdir -p /usr/local/lib/lua/5.4/	# just for ensuring that the dest dir exists
	mkdir -p /usr/local/share/lua/5.4/	# just for ensuring that the dest dir exists
	mv libluabag.dylib /usr/local/lib/lua/5.4/
	#cp luabag.lua /usr/local/share/lua/5.4/
