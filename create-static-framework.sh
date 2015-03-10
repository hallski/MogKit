#!/bin/sh

set -e
export PROJECT_DIR="."
export BUILD_DIR="${PROJECT_DIR}/build"
export PRODUCT_NAME="MogKit"
export TARGET_NAME="MogKit-static"
export PROJECT_FILE_PATH="MogKit.xcodeproj"

export FRAMEWORK_LOCATION="${BUILD_DIR}/${PRODUCT_NAME}.framework"

export HEADER_LOCATION="${BUILD_DIR}/Release-iphoneos/include/${PRODUCT_NAME}"
export UNIVERSIONAL_LIB_LOCATION="${BUILD_DIR}/lib${PRODUCT_NAME}Universal.a"

# Clean old build directory
rm -rf ${BUILD_DIR}

# Create Framework structure
mkdir -p "${FRAMEWORK_LOCATION}/Versions/A"

function build_static_library {
    xcrun xcodebuild                      \
          -project "${PROJECT_FILE_PATH}" \
          -target "${TARGET_NAME}"        \
          -configuration Release          \
          -sdk ${1} -arch ${2}            \
          clean build
}

# Build for simulator
build_static_library iphonesimulator i386
mv "${BUILD_DIR}/Release-iphonesimulator/lib${PRODUCT_NAME}.a" "${BUILD_DIR}/libMogKiti386.a"

build_static_library iphonesimulator x86_64
mv "${BUILD_DIR}/Release-iphonesimulator/lib${PRODUCT_NAME}.a" "${BUILD_DIR}/libMogKitx86_64.a"


# Build armv7
build_static_library iphoneos armv7
mv "${BUILD_DIR}/Release-iphoneos/lib${PRODUCT_NAME}.a" "${BUILD_DIR}/libMogKitArmv7.a"

# Build armv7s
build_static_library iphoneos armv7s
mv "${BUILD_DIR}/Release-iphoneos/lib${PRODUCT_NAME}.a" "${BUILD_DIR}/libMogKitArmv7s.a"

# Build arm64
build_static_library iphoneos arm64
mv "${BUILD_DIR}/Release-iphoneos/lib${PRODUCT_NAME}.a" "${BUILD_DIR}/libMogKitArm64.a"

# Create universal library
lipo -create -output $UNIVERSIONAL_LIB_LOCATION \
    "${BUILD_DIR}/libMogKiti386.a"              \
    "${BUILD_DIR}/libMogKitArmv7.a"             \
    "${BUILD_DIR}/libMogKitArmv7s.a"            \
    "${BUILD_DIR}/libMogKitArm64.a"             \
    "${BUILD_DIR}/libMogKitx86_64.a"

# Copy the headers and universal library into framework
cp -a ${HEADER_LOCATION} "${FRAMEWORK_LOCATION}/Versions/A/Headers"
cp "${UNIVERSIONAL_LIB_LOCATION}" "${FRAMEWORK_LOCATION}/Versions/A/${PRODUCT_NAME}"

# Setup framework links
ln -sfh "Versions/Current/${PRODUCT_NAME}" "${FRAMEWORK_LOCATION}/${PRODUCT_NAME}"
ln -sfh A "${FRAMEWORK_LOCATION}/Versions/Current"
ln -sfh Versions/Current/Headers "${FRAMEWORK_LOCATION}/Headers"

echo "Framework built at ${FRAMEWORK_LOCATION}"
