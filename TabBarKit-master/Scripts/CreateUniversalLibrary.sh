#!/bin/tcsh

# Untested but started as method to create binary distributions of static libraries...

# Create local psudeo-platform

IOS_PLATFORM_NAME_DEVICE = iphoneos
IOS_PLATFORM_NAME_SIMULATOR = iphonesimulator
IOS_PLATFORM_NAME_UNIVERSAL = universal

mkdir -p ${BUILD_DIR}/${CONFIGURATION}-universal

IOS_DEVICE_STATICLIBRARY_PATH    = $(CONFIGURATION)-$(IOS_PLATFORM_NAME_DEVICE)/${FULL_PRODUCT_NAME)
IOS_SIMULATOR_STATICLIBRARY_PATH = $(CONFIGURATION)-$(IOS_PLATFORM_NAME_SIMULATOR)/${FULL_PRODUCT_NAME)
IOS_UNIVERSAL_STATICLIBRARY_PATH = $(CONFIGURATION)-$(IOS_PLATFORM_NAME_UNIVERSAL)/${FULL_PRODUCT_NAME}

# Create a fat static archive binary with contained architecture types (armv6, armv7 and i386 at present)

lipo -create IOS_DEVICE_STATICLIBRARY_PATH IOS_SIMULATOR_STATICLIBRARY_PATH -output IOS_UNIVERSAL_STATICLIBRARY_PATH

# Create shared psudeo-platform and in-between paths if needed.

mkdir -p ${BUILD_SHARED_ROOT_PATH}
mkdir -p ${BUILD_SHARED_BUNDLES_PATH}
mkdir -p ${BUILD_SHARED_LIBRARIES_PATH}
mkdir -p ${BUILD_SHARED_LIBRARIES_PATH/$(CONFIGURATION)/$(EFFECTIVE_PLATFORM_NAME)-universal

# ditto -c -k --keepParent ${PROJECT_DIR}/build/${BUILD_STYLE}-iphoneos/ ${PROJECT_DIR}/build/${BUILD_STYLE}-iphoneos/
