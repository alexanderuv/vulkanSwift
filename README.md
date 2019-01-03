# Vulkan Sample

Steps to set up:

1. We need Swift 5 for this, so download a snapshot from [Swift.org](https://swift.org/download/#snapshots). Install the `.pkg` file.
1. Download Vulkan/MoltenVK from [here](https://vulkan.lunarg.com/sdk/home#mac) and unzip to `$HOME/SDKs`. Example: `$HOME/SDKs/vulkansdk-macos-1.1.92.1`
1. Set up variables in `~/.bash_profile`:
```sh
export TOOLCHAINS="swift" # use downloaded snapshot
export VULKAN_SDK_HOME="$HOME/SDKs/vulkansdk-macos-1.1.92.1/macOS" # make sure this matches the downloaded version
export CUSTOM_PKG_CONFIG="$HOME/pkg-config"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$CUSTOM_PKG_CONFIG"
```
4. After the changes above are in place, create `vulkan.pc` by running this:
```sh
mkdir -p $CUSTOM_PKG_CONFIG # make sure this exists
cat > $CUSTOM_PKG_CONFIG/vulkan.pc << EOF
prefix=$VULKAN_SDK_HOME
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: vulkan
Description: Vulkan SDK
Version: 1.0.69
Libs: -L\${libdir} -lvulkan -lMoltenVK
Cflags: -I\${includedir}
EOF

# if you have a better way of doing this, let me know
ln -s $VULKAN_SDK_HOME/lib/libvulkan.1.dylib /usr/local/lib/ 
ln -s $VULKAN_SDK_HOME/lib/libMoltenVK.dylib /usr/local/lib/
```
5. Confirm right Swift version by running `swift --version`. Should return something like `Apple Swift version 5.0-dev`
6. Run `swift build` at the project's root folder
