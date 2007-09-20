#This un-changes the install paths so they are executable-relative.
#This will make the framework compiler happy again at the cost of making it not runtime happy.
echo "Un-patching binaries to work with ld"

LOCATION=`dirname $0`
CURVERS=$LOCATION/Versions/Current
FRAMEWORKS=$CURVERS/Frameworks

/usr/bin/install_name_tool -id "@executable_path/../Frameworks/ObjC3D.framework/Versions/Current/Frameworks/Cg.framework/Cg" $FRAMEWORKS/Cg.framework/Cg
/usr/bin/install_name_tool -id "@executable_path/../Frameworks/ObjC3D.framework/Versions/Current/Frameworks/Log4Cocoa.framework/Log4Cocoa" $FRAMEWORKS/Log4Cocoa.framework/Log4Cocoa
/usr/bin/install_name_tool -id "@executable_path/../Frameworks/ObjC3D.framework/ObjC3D" $CURVERS/ObjC3D

/usr/bin/install_name_tool -change "@loader_path/Frameworks/Cg.framework/Cg" "@executable_path/../Frameworks/ObjC3D.framework/Versions/Current/Frameworks/Cg.framework/Cg" -change "@loader_path/Frameworks/Log4Cocoa.framework/Log4Cocoa" "@executable_path/../Frameworks/ObjC3D.framework/Versions/Current/Frameworks/Log4Cocoa.framework/Log4Cocoa" $CURVERS/ObjC3D