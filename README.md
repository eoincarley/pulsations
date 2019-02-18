# Pulsation analysis
Codes for analysis of pulsation event on 2014-Apr-18. 

# Requirements
The codes in this repo requires Interactive Data Language (IDL) version 7.x or greater and an up-to-date SolarSoft Installation (with installation instructions here: https://sohowww.nascom.nasa.gov/solarsoft/). Note SolarSoft installation time may take several hours depending on which packages are being downloaded. All code can be run on a standard laptop or desktop (currently runs smoothly on iMac with 32 Gb RAM and 3.2 GHz processor).

# Data Access

The the radio data sets are available in the Nancay archives at http://secchirh.obspm.fr. Any AIA or HMI datasets are available at the SDO data archive and can be donwloaded using the relevant SolarSoft VSO packages. FERMI data can be obtained using the standard RHESSI GUI in SolarSoft. RSTN data can be obtained from ftp://ftp.ngdc.noaa.gov/STP/space-weather/solar-data/solar-features/solar-radio/rstn-1-second/

# Data processing

All data were processed using the standard packages in SolarSoft. For example:

- AIA was preprocessed using aia_prep.pro and plot using the standard plot_map.pro routines.
- NRH visibilities were processed to images and CLEANed using the standard nrh GUI in SolarSoft. The default CLEAN parameters were used. Note that NRH visibilities to image processing and CLEANing may take several hours
on a standard machine.
- Orfées and NDA were background subtracted and plot using the standard routines of the ETHZ package e.g., spectro_plot.pro.
- The DEM maps were produce using the packages available at http://www.lmsal.com/~cheung/AIA/tutorial_dem/

# Example
To reproduce Figure 2a-b run

.r plot_figure2ab

plot_figure2ab

To reproduce Figure 3a run

.r plot_figure3a

plot_figure3a

Note: the paths to the data on your local machine will need to be edited withing these codes.

For any information on the codes or data necessary to reproduce the plots, please email eoincarley@gmail.com