# Fedora coreOS notes

## Butane and ignition

Butane is used for a user-friendly way to create ignition files for Fedora CoreOS.

**Create ignition file from butane config:**

```bash
butane --pretty --strict config.bu > config.ign
```

## Installation

Once you have booted the Fedora CoreOS ISO, you can install it using the `coreos-installer` command.
 Its easier if you have the ignition file hosted somewhere accessible via URL.

**Install Fedora CoreOS to disk:**

```bash
coreos-installer install /dev/sda --image-url <URL_to_Fedora_CoreOS_image> --ignition-file <URL_to_ignition_file>
```