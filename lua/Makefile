
linux:
	clang -O2 -fPIC -Wall -shared -o libluabag.so libluabag.c -llua
	
	
install:
	mkdir -p /usr/local/lib/lua/5.4/	# just for ensuring that the dest dir exists
	mkdir -p /usr/local/share/lua/5.4/	# just for ensuring that the dest dir exists
	mv libluabag.so /usr/local/lib/lua/5.4/
	#cp luabag.lua /usr/local/share/lua/5.4/