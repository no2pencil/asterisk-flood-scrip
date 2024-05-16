Purpose - Using a generic text menu, auto generation of dial files for use with Asterisk, along with a call counter.

Usage - Run auto.calls.sh from the cli, may require sudo depending on your setup.

Once the script is run, you'll be in the main menu.  From here you can select "Configure".  This allows you to set the values for the dial files, how often to make calls, & some directories for your system.

From the main menu, when you select "Dial", using the values provided in the configuration dial files are generated & copied to the spooler directory.

The file areacodes.txt contains some of the more popular area codes.  This was in an effort to cut down on junk caller ids when generating them randmoly.  Starting with more popular cities will create more realistic calls.  Feel free to edit this file as you see fit.

Best of luck, enjoy.
-#2pencil-
