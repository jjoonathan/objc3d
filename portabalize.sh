#!/bin/sh
#This changes the install paths to be loader relative rather than executable relative.
#In other words, the library will be embed-able in a bundle or loadable as a bundle afterwards. Unfortunately, ld doesn't recognize loader_path even though dyld does so you will get compiler trouble. ONLY RUN THIS SCRIPT IF YOU ARE NOT EMBEDDING IN A REGULAR APP!
echo "Patching binaries to work with tiger dyld"

LOCATION=`dirname $0`
CURVERS=$LOCATION/Versions/Current
FRAMEWORKS=$CURVERS/Frameworks

/usr/bin/install_name_tool -id "@loader_path/Frameworks/Cg.framework/Cg" $FRAMEWORKS/Cg.framework/Cg
/usr/bin/install_name_tool -id "@loader_path/Frameworks/Log4Cocoa.framework/Log4Cocoa" $FRAMEWORKS/Log4Cocoa.framework/Log4Cocoa
/usr/bin/install_name_tool -id "@loader_path/../Frameworks/ObjC3D.framework/ObjC3D" $CURVERS/ObjC3D

/usr/bin/install_name_tool -change "@executable_path/../Frameworks/ObjC3D.framework/Versions/Current/Frameworks/Cg.framework/Cg" "@loader_path/Frameworks/Cg.framework/Cg" -change "@executable_path/../Frameworks/ObjC3D.framework/Versions/Current/Frameworks/Log4Cocoa.framework/Log4Cocoa" "@loader_path/Frameworks/Log4Cocoa.framework/Log4Cocoa" $CURVERS/ObjC3D