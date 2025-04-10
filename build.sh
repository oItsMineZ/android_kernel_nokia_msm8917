abort()
{
    cd -
    echo "---------------------------------------------------------"
    echo "-- Kernel compilation failed! Exiting..."
    echo "---------------------------------------------------------"
    if [[ "$LOCAL" == "y" ]]; then
        FUNC_CLEANUP
    fi
    exit -1
}

FUNC_CHECKENV()
{
    DATE=`date +"%Y%m%d"`
    export KBUILD_BUILD_USER="oItsMineZ"

    if [ -n $RELEASE ]; then
        echo "---------------------------------------------------------"
        echo "-- Running on GitHub Actions..."
        export KBUILD_BUILD_HOST="GitHub-Actions"
    else
        echo "---------------------------------------------------------"
        echo "-- Running on Local Machine..."
        export KBUILD_BUILD_HOST="Linux-Stable"
        LOCAL=y
    fi
}

RDIR=$(pwd)
CPU=`grep -c ^processor /proc/cpuinfo`
GCC=$RDIR/toolchain/arm-linux-androideabi-4.9/bin/
ARGS="
    ARCH=arm O=out \
    KCFLAGS=-mno-android \
    CROSS_COMPILE=${GCC}arm-linux-androideabi- \
"

# Define specific variables
KERNEL_DEFCONFIG=oitsminez-E2M-perf_defconfig
DEVICE="Nokia 2.1"
MODEL="E2M"
SOC="Snapdragon 425"

if [ -z $KERNEL_VERSION ]; then
    KERNEL_VERSION="Unofficial"
fi

FUNC_TOOLCHAIN()
{
    echo "---------------------------------------------------------"
    echo "-- Checkout Toolchain Repo..."
    echo "---------------------------------------------------------"

    git submodule add --branch master --force https://github.com/KudProject/arm-linux-androideabi-4.9 toolchain/arm-linux-androideabi-4.9
}

FUNC_BUILD_KERNEL()
{
    # Build kernel image
    echo "---------------------------------------------------------"
    echo "-- Device: "$MODEL""
    echo "-- SOC: Exynos$SOC"
    echo "-- Defconfig: "$KERNEL_DEFCONFIG""
    echo "-- Kernel Version: $KERNEL_VERSION"

    echo -e "CONFIG_LOCALVERSION_AUTO=n" > $RDIR/arch/arm/configs/version.config

    if [ -n $RELEASE ]; then
        echo BUILD_DEVICE=$DEVICE >> $GITHUB_ENV
    fi

    echo -e "CONFIG_LOCALVERSION=\"-oItsMineZKernel-"$KERNEL_VERSION"-"$DEVICE"\"" >> $RDIR/arch/arm/configs/version.config
    DEFCONFIG="$KERNEL_DEFCONFIG version.config"

    echo "---------------------------------------------------------"
    echo "-- Building Kernel Using "$KERNEL_DEFCONFIG""
    echo "-- Generating Configuration Files..."
    echo "---------------------------------------------------------"

    make -j$CPU $ARGS $DEFCONFIG || abort

    echo "---------------------------------------------------------"
    echo "-- Building Kernel..."
    echo "---------------------------------------------------------"

    make -j$CPU $ARGS || abort

    echo "---------------------------------------------------------"
    echo "-- Finished Kernel Build!"
    echo "---------------------------------------------------------"

    rm -rf $RDIR/build/out/$MODEL
    mkdir -p $RDIR/build/out/$MODEL
}

FUNC_BUILD_RAMDISK()
{
    # Build ramdisk
    echo "---------------------------------------------------------"
    echo "-- Building Ramdisk..."
    echo "---------------------------------------------------------"

    rm -f $RDIR/build/AIK/split_img/boot.img-kernel
    cp $RDIR/out/arch/arm64/boot/Image $RDIR/build/AIK/split_img/boot.img-kernel

    # Create boot image
    echo "-- Creating Boot Image..."
    echo "---------------------------------------------------------"

    cd $RDIR/build/AIK/
    ./repackimg.sh --nosudo
}

FUNC_BUILD_ZIP()
{
    # Build zip
    echo "---------------------------------------------------------"
    echo "-- Building Zip..."
    if [[ "$LOCAL" == "y" ]] || [[ "$RELEASE" == "y" ]]; then
        echo "---------------------------------------------------------"
    fi

    rm -rf $RDIR/build/out/$MODEL/zip
    mkdir -p $RDIR/build/export
    mkdir -p $RDIR/build/out/$MODEL/zip
    mkdir -p $RDIR/build/out/$MODEL/zip/META-INF/com/google/android
    mv $RDIR/build/AIK/image-new.img $RDIR/build/out/$MODEL/boot-patched.img

    # Make recovery flashable package
    cp $RDIR/build/out/$MODEL/boot-patched.img $RDIR/build/out/$MODEL/zip/boot.img
    cp $RDIR/build/update-binary $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/
    cp $RDIR/build/updater-script $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/

    sed -i "s/ui_print(\" Kernel Version: \");/ui_print(\" Kernel Version: $KERNEL_VERSION\");/" $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s/ui_print(\" Kernel Device: \");/ui_print(\" Kernel Device: $DEVICE ($MODEL)\");/" $RDIR/build/out/$MODEL/zip/META-INF/com/google/android/updater-script
    sed -i "s/CONFIG_LOCALVERSION=\"-oItsMineZKernel-"$KERNEL_VERSION"-"$DEVICE"\"/CONFIG_LOCALVERSION=\"-oItsMineZKernel-"$KERNEL_VERSION"-"$DATE"-"$DEVICE"\"/" $RDIR/arch/arm64/configs/version.config

    version=$(grep -o 'CONFIG_LOCALVERSION="[^"]*"' $RDIR/arch/arm/configs/version.config | cut -d '"' -f 2)
    version=${version:1}
    NAME="$version"-"$MODEL".zip

    if [[ "$LOCAL" == "y" ]] || [[ "$RELEASE" == "y" ]]; then
        cd $RDIR/build/out/$MODEL/zip
        zip -r ../"$NAME" .
        rm -rf $RDIR/build/out/$MODEL/zip
        mv $RDIR/build/out/$MODEL/"$NAME" $RDIR/build/export/"$NAME"
        cd $RDIR/build/export
    fi
}

FUNC_CLEANUP()
{
    echo "---------------------------------------------------------"
    echo "-- Cleanup build files..."
    echo "---------------------------------------------------------"

    cd $RDIR && rm -rf out
    rm -rf .wireguard-fetch-lock
    rm -rf arch/arm64/configs/version.config
    rm -rf build/AIK/split_img/boot.img-kernel
    git rm -rf toolchain

    git reset --hard HEAD && git clean -df
}

# MAIN FUNCTION
rm -rf ./build.log
(
    START_TIME=`date +%s`

    echo "---------------------------------------------------------"
    echo "-- Preparing the Build Environment..."

    if test -d "$DIR/toolchain"; then
        echo "---------------------------------------------------------"
        echo "-- Toolchain Directory Found!"
        echo "---------------------------------------------------------"
    else
        FUNC_TOOLCHAIN
    fi

    FUNC_BUILD_KERNEL
    FUNC_BUILD_RAMDISK
    FUNC_BUILD_ZIP

    if [[ "$LOCAL" == "y" ]]; then
        FUNC_CLEANUP
    fi

    END_TIME=`date +%s`

    let "ELAPSED_TIME=$END_TIME-$START_TIME"

    echo "---------------------------------------------------------"
    echo "-- Total compile time was $(($ELAPSED_TIME / 60)) minutes and $(($ELAPSED_TIME % 60)) seconds"
    echo "---------------------------------------------------------"
) 2>&1	| tee -a ./build.log
