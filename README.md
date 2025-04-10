# oItsMineZKernel for Android 10 Nokia 2.1

<img src="https://fdn2.gsmarena.com/vv/pics/nokia/nokia-21-1.jpg" style="width: 200px;" alt="logo">

Stock Kernel with Linux Stable upstream (3.18.124 --> 3.18.140 + LA.UM.8.6.r1-05300-89xx.0) based on [Kernel Source](https://github.com/Dynamo8917/android_kernel_nokia_msm8917) by [`Project Dynamo`](https://github.com/Dynamo8917)

## Features

- Kernel Based on 00WW_4_11I (Android 10)
- WireGuard
- CPU Input Boost
- OC for Little, Mid and Big CPU
- HZ Tick Set at 25Hz
- Boeffla Wakelock Blocker

## How to Install
- Flash Zip file via `TWRP` (You can get TWRP Recovery [here](https://github.com/Dynamo8917/android_recovery_fih_E2M))

## Supported Devices:


|       Name        |  Codename/Model  |
:------------------:|:----------------:|
|     Nokia 2.1     |       E2M        |
|     Nokia 2V      |       EVW        |

## Build Instructions:

1. Set up build environment as per Google documentation

   <a href="https://source.android.com/docs/setup/start/requirements" target="_blank">https://source.android.com/docs/setup/start/requirements</a>

2. Clone repository

```
git clone https://github.com/oItsMineZKernel/android_kernel_nokia_msm8917
```

3. Build for your device

```
./build.sh
```

4. Fetch the flashable zip of the kernel that was just compiled

```
build/export/oItsMineZKernel-Unofficial-[your_device].zip
```

5. Flash it using a supported recovery like TWRP

6. Enjoy!

## Credits

- [`Project Dynamo`](https://github.com/Dynamo8917) for [Kernel Source](https://github.com/Dynamo8917/android_kernel_nokia_msm8917)
- [`Batu33TR`](https://github.com/Batu33TR) for [ProjectMedusa Kernel](https://github.com/ProjectMedusaAndroid/android_kernel_samsung_msm8917_Q)
- [`Chococatpp`](https://github.com/Chococatpp) for [ProjectSoraki Kernel](https://github.com/Chococatpp/android_kernel_samsung_msm8917_Q)