# general_bio
A repository containing general scripts that are useful within bioinformatics

- idat_finder.sh: Has your Illumina microarray service provider always provided you with more data then necessary? Are you tired of having to sift through the different folders to look for the .idat files? Are you simply tired of CTRL-F/C/V'ing your way through the resultant files? If you answered "yes" to the abovementioned questions, then idat_finder.sh has your back! This bash script seeks to remove the manual labor necessary by finding all the necessary .idat files and placing them in an output folder. This script needs only two mandatory arguments:
- -s: A sample/phenosheet containing the chip barcodes (Sentrix IDs) and positions. 
- -f: A source folder containing the subfolders, which contain the .idat files as provided by your service provider.

 Optional arguments include:
- -o: Output folder that will contain the subdirectories, which in turn contain the .idat files. If left blank, the script will create its own "output" folder from the location you ran it from.
- -d: Switches off the subdirectories made for each chip (Sentrix ID)
- -v: Switches on verbose messages.
- -h: Basic help function.

	Notes:
- Running this script on .idat files that are located on an external filesource has proven to be rather slow. would advise hauling all the entire source directory onto the local drive if possible and then running this.
- So far I have found that the Sentrix IDs are comprised of either 10 or 12 digits. I have hardcoded this limit the regex. It is possible to change this to "^[0-9]+$" but you should then ensure that your phenodata does contain any columns other than the Sentrix IDs that are comprised solely of digits.
