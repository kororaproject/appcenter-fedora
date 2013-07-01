prefix=@PREFIX@
exec_prefix=@DOLLAR@{prefix}
libdir=@DOLLAR@{prefix}/lib
includedir=@DOLLAR@{prefix}/include/
 
Name: AppCenter
Description: AppCenter headers  
Version: 0.1  
Libs: -lappcentercore
Cflags: -I@DOLLAR@{includedir}/appcentercore
Requires: gtk+-3.0 gee-1.0 granite appstore
