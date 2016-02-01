Pass for iOS
============

![Icon](https://raw.github.com/davidjb/pass-ios/master/Resources/Icon@3x.png)

View your [pass password store][] passwords on your iDevice.

[pass password store]: http://www.passwordstore.org

Features
--------

* Access and decrypt GPG-based files within your Pass-compatible store
* Copy passwords to pasteboard or display on screen
* View or copy multi-line Pass content
* Resets pasteboard contents after 45 seconds when copying data
* TouchID authentication for storing GPG passphrase

Dependencies
------------

The following packages are available from Cydia:

* gnupg  (required)
* git    (optional)

Setup
-----

1. Install the app itself.

   See https://github.com/davidjb/pass-ios/releases for a list of available
   pre-built `.deb` packages, or follow the instructions below to build your
   own.

2. Copy your `pass` password-store to `/var/mobile/.password-store`.

   The simplest way to do this is to store your passwords in a `git` repository,
   which you can then clone onto your device. Alternatively, you can use SCP,
   iFile or any other method to transfer the passwords over.

3. Set up your gpg key:

  1. Export your *private* key from your desktop, laptop or other computer:

     ```
     (desktop)$ gpg --export-secret-key --armor ${KEY_ID} > ${KEY_ID}.asc
     ```

  2. Copy this file to your iOS device

  3. On the device, import the key:

     ```
     (device)$ gpg --import ${KEY_ID}.asc
     ```

  4. Delete the key file

  5. Test decrypting one of your passwords

     ```
     (device)$ gpg -d ~/.password-store/ENTRY.gpg
     ```

4. Launch and begin using the Pass app!

Using the app
-------------

After launching the app, you will be presented with a listing of files and
directories in `~/.password-store`. Files starting with '.' are hidden, and
`.gpg` extensions are stripped.

![Main Screen](https://raw.github.com/davidjb/pass-ios/screenshots/screenshots/1_main_screen.png)

Clicking on a directory will show its contents.

![Subdirectory Listing](https://raw.github.com/davidjb/pass-ios/screenshots/screenshots/2_subdir.png)

Clicking on a password file will show a screen with the password file details (name and \*'d out password).

![Subdirectory Listing](https://raw.github.com/davidjb/pass-ios/screenshots/screenshots/3_entry.png)

Clicking on the name or password box will copy the respective contents to the pasteboard (clipboard). Since the password is encrypted, you will have to enter you passphrase before it can be copied.

![Subdirectory Listing](https://raw.github.com/davidjb/pass-ios/screenshots/screenshots/4_gpg.png)

Building
--------

1. Obtain the iPhone SDK, usually done via Xcode.

2. Build using the following:

   ```
   git clone --recursive https://github.com/davidjb/pass-ios.git
   cd pass-ios

   # ldid compilation only required first time
   cd modules/ldid
   ./make.sh
   cd ../..

   source .env
   make
   make package
   ```

   This clones and configures the theos environment for building.

3. Install directly your device over SSH with:

   ```
   export THEOS_DEVICE_IP=[device IP]
   make install

   # or to clean, build and install in one
   make build-install
   ```

   Ensure that you have access to root on your device via SSH.

If your newly installed app doesn't appear, run `uicache` on your device via
SSH.  This will typically only be on first install or if you've updated a
visual aspect that would appear on the home screen.

Contributing
------------

You're awesome -- all help is greatly appreciated!  Just fork and submit a
pull request on GitHub. For major changes or new features, consider opening
an issue first for discussion; this may save you a bunch of time in coding!

If you're not sure where to start contributing, take a look at the 
[issue tracker](https://github.com/davidjb/pass-ios/issues)
to see the current list of bugs to solve or features to implement, and consult
the todo list below.

Todo
----

* Simplify initial setup

  - enter git repo url to clone
  - paste gpg key
  - investigate becoming an official App Store app

* Better details screen

  - Change UI table cells when displaying passwords (temporarily)

* Configurable Settings

  - allow showing passwords on screen rather than copying
  - base directory location (other than /var/mobile/.password-store)
  - whether to store passphrase in keychain
  - passphrase storage duration (X minutes or forever)
  - pasteboard reset time

* Password editing / adding
  - auto-commit ala pass bash script
  - trigger 'git pull' from app (also 'git push' after editing is implemented)
