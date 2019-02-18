;  This sample script demonstrates how to download a pre-compuated PFSS
;  coronal field model, and then trace and visualize some field lines. 

;  To use, do a  .r pfss_sample1  (this file) at the IDL> prompt.

;  M.DeRosa -  3 Mar 2004 - created
;             22 Aug 2006 - added trackball stuff

;  include common block (not necessary but useful for looking at things...)
@pfss_data_block

;  first restore the file containing the coronal field model

;  date/time is set here to Apr 5, 2003 for demonstration purposes, but any
;  SSW formatted date/time will do
pfss_restore,pfss_time2file('2014-04-18',/ssw_cat,/url)  ;  for all users
;pfss_restore,pfss_time2file('2003-04-05')   ;  for users at LMSAL

;  starting points to be on a regular grid covering the full disk, with a
;  starting radius of r=1.5 Rsun
invdens = 10 ;  factor inverse to line density, i.e. lower values = more lines
pfss_field_start_coord,5,invdens,radstart=1.5

;  trace the field lines passing through the starting point arrays
pfss_trace_field

;  render field, one can use pfss_draw_field3 to get line crossings correct
bcent=30.0  ;  central latitude of projection in degrees
lcent=90.0  ;  central Carrington longitude of projection in degrees
width=2.5  ;  image out to 2.5 R_sun   \  together these keywords produce
mag  =2    ;  magnification factor     /  a 720x720 image (below, in outim)
imsc =200  ;  data values at which image of background magnetogram saturates
pfss_draw_field,outim=outim,bcent=bcent,lcent=lcent,width=width,mag=mag,imsc=imsc

;  get color table (only needs to be done once)
loadct,0  ;  loadct,3 also looks nice too
tvlct,re,gr,bl,/get
re(250:255)=[0b,0b,255b,255b,255b,255b]
gr(250:255)=[255b,255b,0b,0b,255b,255b]
bl(250:255)=[0b,0b,255b,255b,255b,255b]
tvlct,re,gr,bl

;  display
nax=size(outim,/dim)
window,0,xsiz=nax(0),ysiz=nax(1)
tv,outim

;  do trackball
print,'  Type .c for trackball widget'
pfss_to_spherical,pfss_data
spherical_trackball_widget,pfss_data

end
