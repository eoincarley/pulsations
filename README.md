# Pulsation analysis
Codes for analysis of pulsation event on 2014-Apr-18. 

# Requirements
The codes in this repo requires Interactive Data Language (IDL) version 7.x and greater and an up-to-date SolarSoft Installation (with installation instructions here: https://sohowww.nascom.nasa.gov/solarsoft/). Note SolarSoft installation time may take several hours depending on which packages are being downloaded. All code can be run on standard laptop or desktop (currently runs smoothly on iMac with 32 Gb RAM and 3.2 GHz processor).

# Data Access

The NRH datasets analysed during the current study are available in the Nancay Radioheliograph archive at http://secchirh.obspm.fr/nrh data.php. Orfées data is aavilable at http://secchirh.obspm.fr/spip.php?article10. Any AIA or HMI datasets are available at the SDO data archive and can be donwloaded using the relevant SolarSoft VSO packages. Magnetic field extrapolations can be performed through the standard SolarSoft packages.

For any supplementary data necessary to run these codes, please email eoincarley@gmail.com

# Example
To plot GOES, Orfées, NDA as in Figure 2a-b simply run
.r plot_figure2ab
plot_figure2ab
