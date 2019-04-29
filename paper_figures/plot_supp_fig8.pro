;;
;
; N.B. same as the code goes_rhessi_fermi_dam_orfees.pro for the 2014-April-18 event paper,
; but this one is checking for any relationship amongst FERMI and RHESSI to the pulsations
; at 208 MHz in Orfées.
;

pro setup_ps, name
  
   set_plot,'ps'
   !p.font=0
   !p.charsize=1.0
   device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=9, $
          ysize=12, $
          /encapsulate, $
          yoffset=5, $
          bits_per_pixel = 16

END

pro plot_radio_flux, orf_spec, orf_time, orf_freqs, nrh_times, nrh_flux, trange, $
	plt_pos=plt_pos, long_duration=long_duration, ylog=ylog, yrange=yrange, smoothing=smoothing, xtickfmt=xtickfmt, xtitle=xtitle


	set_line_color
	utplot, nrh_times, nrh_flux, $  ; NRH flux
		/xs, $
		/ys, $
		ylog=ylog, $
		/nodata, $
		ytitle='NRH Flux (SFU)', $
		xtickformat=xtickfmt, $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = xtitle, $
  		yr=yrange, $
		position = plt_pos, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=6		

	data = read_csv('~/Data/2014_apr_18/pulsations/nrh2_2280_f70_FAR_20140418_123947c53_i.asc') ; Flare radio source
	FAR_flux = float(((strsplit(data.field1, ' ', /extract)).toarray())[*, 0]) 
	FAR_time = transpose('2014-04-18T'+((strsplit(data.field1, ' ', /extract)).toarray())[*, 1])
	for i=0, n_elements(FAR_time)-1 do FAR_time[i] = strmid(FAR_time[i], 0, 19)
	loadct, 0
	outplot, anytim(FAR_time, /utim), smooth(FAR_flux*0.5, smoothing), color=100, thick=3.0, linestyle=3		

	set_line_color
	if keyword_set(long_duration) then begin
		restore,'~/Data/2014_apr_18/pulsations/long_dur_flux/nrh_228_flux_long_duration.sav', /verb
		times = anytim(FLUX_STRUCT.times, /utim) 
		flux = FLUX_STRUCT.flux_density
		outplot, times, smooth(flux, smoothing), color=6, thick=5.0
	endif else begin	
		outplot, nrh_times, nrh_flux, color=6, thick=4.5

		loadct, 5, /silent
		freq_array = reverse(orf_freqs)
		index = closest(freq_array, 208)
		lcurve = smooth(orf_spec[*, index], 10)
		;utplot, orf_time, lcurve, $
		;	ylog=ylog, $
		;	/xs, $
		;	/ys, $
		;	linestyle = 0, $
		;	color = 80, $
		;	xticklen=-1e-5, $
		;	yticklen=-1e-5, $
		;	ytitle = ' ', $
		;	xtitle = ' ', $
		;	thick=2, $
		;	ytickformat='(A1)', $
		;	xtickformat='(A1)', $
		;	position = plt_pos, $
		;	xr = trange, $
		;	yr=[0.1, 1.3], $
		;	/normal, $
		;	/noerase
	endelse			

	set_line_color	

END

pro plot_rstn, t0, t1, pos=pos, oplot=oplot
	
	file = '~/Data/2014_apr_18/radio/rstn/18apr14.lis'
	time_base = anytim('2014-04-18T12:15:00', /utim)
	;t0=anytim('2014-04-18T12:55:00', /utim)
	;t1=anytim('2014-04-18T12:58:00', /utim)

	result = read_ascii(file, data_start=30363)
	data = result.field1
	dshape = size(data)
	nseconds = dshape[2]
	nfreqs = dshape[1]
	times = time_base + findgen(nseconds)
	tindices = where(times ge t0 and times le t1)
	freqs = ['245', '410', '610', '1415', '2695', '4995', '8800', '15400']
	colors = indgen(9)
	linestyle = [1,2,3,6,5,6,7,8,9]

	if ~keyword_set(oplot) then begin
		set_line_color
		factor=1
		rstn_flux = data[5, tindices]
		rstn_flux = rstn_flux-mean(rstn_flux[0:10])
		utplot, times[tindices], rstn_flux, color=0, $
			position=pos, xr=[t0,t1], /xs, /ys, /noerase, yr=[0, 1200], xtitle='Time (UT)', $
			xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, ytitle='Flux (SFU)', thick=3, linestyle=linestyle[0]
		outplot, times[tindices], rstn_flux, color=colors[5], thick=2, linestyle=linestyle[0]

		rstn_flux = data[6, tindices]
		rstn_flux = rstn_flux-min(rstn_flux[0:10])
		outplot, times[tindices], rstn_flux, color=0, thick=3, linestyle=linestyle[1]
		outplot, times[tindices], rstn_flux, color=colors[6], thick=2, linestyle=linestyle[1]

		rstn_flux = data[7, tindices]
		rstn_flux = rstn_flux-min(rstn_flux[0:10])
		outplot, times[tindices], rstn_flux, color=0, thick=3, linestyle=linestyle[2]
		outplot, times[tindices], rstn_flux, color=colors[7], thick=2, linestyle=linestyle[2]

		rstn_flux = data[8, tindices]
		rstn_flux = rstn_flux-min(rstn_flux[0:10])
		outplot, times[tindices], rstn_flux, color=0, thick=3, linestyle=linestyle[3]
		outplot, times[tindices], rstn_flux, color=colors[8], thick=2, linestyle=linestyle[3]

		xyouts, 0.71, pos[3]-0.015, 'RSTN - San-Vito', /normal, charsize=0.8, color=0
		legend, freqs[[4,5,6,7]]+' MHz', color=colors[[5,6,7,8]], linestyle=[1,2,3,6], box=0, /top, /right, charsize=0.7, thick=4
	endif else begin
		factor=0
		findex=6
		utplot, times[tindices], data[findex, tindices], color=0, yr=[850, 1400], pos=pos, $
			xtickformat='(A1)', ytickformat='(A1)', /noerase, $
			xr=[t0,t1], /xs, /ys, thick=3, xtitle=' ', linestyle=linestyle[1], yticklen=-1e-5
		outplot, times[tindices], data[findex, tindices], color=colors[findex], thick=2, linestyle=linestyle[1]

		axis, yaxis=1, yr=[850, 1400], ytitle='RSTN flux (SFU)', yticklen=-1e-2, charsize=0.7

	endelse	
		
END


pro read_dam, date_string, $
	dam_spec, dam_times, dam_freqs

	restore, 'NDA_'+date_string+'_1051.sav', /verb
	dam_freqs = nda_struct.freq
	daml = nda_struct.spec_left
	damr = nda_struct.spec_right
	times = nda_struct.times

	restore, 'NDA_'+date_string+'_1151.sav', /verb
	daml = [daml, nda_struct.spec_left]
	damr = [damr, nda_struct.spec_right]
	times = [times, nda_struct.times]

	restore, 'NDA_'+date_string+'_1251.sav', /verb
	daml = [daml, nda_struct.spec_left]
	damr = [damr, nda_struct.spec_right]
	times = [times, nda_struct.times]
	
	dam_spec = damr + daml
	dam_times = times

END

pro plot_spec, data, time, freqs, frange, trange, scl0=scl0, scl1=scl1, plt_pos=plt_pos
	

	print, 'Processing: '+string(freqs[0], format=string('(I4)')) + $
			' to ' + $
			string(freqs[n_elements(freqs)-1], format=string('(I4)'))+ ' MHz'

	trange = anytim(file2time(trange), /utim)
	spectro_plot, data > (scl0) < (scl1), $
  				time, $
  				freqs, $
  				/xs, $
  				/ys, $
  				/ylog, $
				XTICKFORMAT="(A1)", $
				YTICKFORMAT="(A1)", $
				xtitle=' ', $
  				;ytitle='Frequency (MHz)', $
  				;title = 'Orfees and DAM', $
  				yr=[ frange[0], frange[1] ], $
  				xrange = [ trange[0], trange[1] ], $
  				/noerase, $
  				position = plt_pos, $
  				xticklen = -0.012, $
  				yticklen = -0.015

  	set_line_color
	cgColorbar, Range=[scl0, scl1], $
       OOB_Low='rose', OOB_High='charcoal', /vertical, /right, title='Normalised Flux', $
       position = [0.9, plt_pos[1], 0.91, plt_pos[1]+0.15 ], charsize=1.0, color=0, OOB_FACTOR=0.0, format='(f3.1)', $
       TICKINTERVAL = 0.2

    loadct, 74
    reverse_ct
  	cgColorbar, Range=[scl0, scl1], $
       OOB_Low='rose', OOB_High='charcoal', title='  ', /vertical, /right, $
       position =  [0.9, plt_pos[1], 0.91, plt_pos[1]+0.15 ], charsize=1.0, color=100, ytickformat='(A1)', OOB_FACTOR=0.0, format='(f3.1)', $
       TICKINTERVAL = 0.2			
		  	
END

function read_goes_txt, file

	readcol, file, y, m, d, hhmm, mjd, sod, short_channel, long_channel
	
	;-------- Time in correct format --------
	time  = strarr(n_elements(y))
	
	time[*] = string(y[*], format='(I04)') + string(m[*], format='(I02)') $
	  + string(d[*], format='(I02)') + '_' + string(hhmm[*], format='(I04)')
	    
	time = anytim(file2time(time), /utim) 
	
	;------- Build data array --------------

	goes_array = dblarr(3, n_elements(y))
	goes_array[0,*] = time
	goes_array[1,*] = long_channel
	goes_array[2,*] = short_channel
	return, goes_array

END

;**********************************************;
;				Plot GOES

pro plot_goes, t1, t2, plt_pos=plt_pos

		x1 = anytim(file2time(t1), /utim)
		x2 = anytim(file2time(t2), /utim)
		
		;--------------------------------;
		;			 Xray
		file = findfile('~/Data/2014_apr_18/goes/20140418_Gp_xr_1m.txt')
		goes = read_goes_txt(file[0])
	
		set_line_color
		utplot, goes[0,*], goes[1,*], $
				thick = 1, $
				;tit = '1-minute GOES-15 Solar X-ray Flux', $
				ytit = 'Watts m!U-2!N', $
				xtit = ' ', $
				color = 3, $
				xrange = [x1, x2], $
				XTICKFORMAT="(A1)", $
				/xs, $
				yrange = [1e-9,1e-3], $
				/ylog, $
				position = plt_pos, $
				/normal, $
				/noerase
				
		outplot, goes[0,*], goes[2,*], color=5	
		
		axis, yaxis=1, ytickname=[' ','A','B','C','M','X',' ']
		axis, yaxis=0, yrange=[1e-9, 1e-3]
		
		i1 =  closest(goes[0,*], x1)
		i2 = closest(goes[0,*], x2)
		plots, goes[0, i1:i2], 1e-8
		plots, goes[0, i1:i2], 1e-7
		plots, goes[0, i1:i2], 1e-6
		plots, goes[0, i1:i2], 1e-5
		plots, goes[0, i1:i2], 1e-4
				
		legend, ['GOES15 0.1-0.8nm','GOES15 0.05-0.4nm'], $
				linestyle=[0,0], $
				color=[3,5], $
				box=0, $
				pos = [0.12, 0.98], $
				/normal, $
				charsize=1.2, $
				thick=3

		xyouts, 0.925, 0.96, 'a', /normal		

END

;**********************************************;
;				Plot RHESSI

pro plot_RHESSI, t0, t1, plt_pos=plt_pos

	search_network, /enable		; To enable online searches
	use_network

	t0_rhessi = anytim(file2time(t0), /atimes)
	t1_rhessi = anytim(file2time(t1), /atimes)

	obj = hsi_obs_summary()
	obj -> set, obs_time_interval=[t0_rhessi, t1_rhessi]
	d1 = obj -> getdata()
	data = d1.countrate
	times_rate = obj -> getaxis(/ut) 

	set_line_color
	plot_indeces = where(times_rate gt anytim('2014-04-18T12:50:00', /utim))

	utplot, times_rate[plot_indeces], data[0, plot_indeces], $
			thick=5, $
			/xs, $ 
			/ys, $
			/ylog, $
			xr=anytim([file2time(t0), file2time(t1)], /utim), $
			yr = [1, 1e4], $
			XTICKFORMAT="(A1)", $
			xtitle=' ', $
			ytitle='Count Rate (s!U-1!N detector!U-1!N)', $
			color=6, $
			pos = plt_pos, $
			/noerase, $
			/normal

	colors = [6,3,4,5,7,10];6,3,4,5];,7,8,10];,8,9,10, 0,2,3,4,5]		

	for i=1, n_elements(data[*, 0])-5 do begin
		counts = data[i, plot_indeces]
		outplot, times_rate[plot_indeces], counts, $
			color = colors[i], $
			thick=5
	endfor			

	flags = obj -> getdata(class='flag')
	times = obj -> getaxis(/ut, class='flag')
	info = obj -> get(/info, class='flag')

	saa_index = where( (flags.flags)[0,*] eq 1)
	night_index = where( (flags.flags)[1,*] eq 1)

	night_time0 = times_rate[night_index[0]]
	night_time1 = times_rate[night_index[n_elements(night_index)-1]]

	vline, night_time0, color=10, thick=4
	vline, night_time1, linestyle=2, color=10, thick=4
	plots, [night_time0, night_time1], [7000, 7000], color=10, thick=4

	saa_time0 = times_rate[saa_index[0]]
	saa_time1 = times_rate[saa_index[n_elements(saa_index)-1]]

	vline, saa_time0-60*4.0, color=9, thick=5
	;vline, saa_time1-60*5.0, color=6, thick=4
	plots, [saa_time0-60*4.0, saa_time1], [7000, 7000], color=9, thick=5

	i1 = obj->get(/info)
	energies = i1.energy_edges

	energies_str = strcompress(string(energies, format='(I5)'))
	energies_legend = [ energies_str[0]+' -'+energies_str[1] + ' keV', $
						energies_str[1]+' -'+energies_str[2] + ' keV', $
						energies_str[2]+' -'+energies_str[3] + ' keV', $
						energies_str[3]+' -'+energies_str[4] + ' keV', $
						energies_str[4]+' -'+energies_str[5] + ' keV', $
						energies_str[5]+' -'+energies_str[6] + ' keV', $
						energies_str[6]+' -'+energies_str[7] + ' keV', $
						energies_str[7]+' -'+energies_str[8] + ' keV', $
						energies_str[8]+' -'+energies_str[9] + ' keV' ]
					

	xyouts, 0.14, 0.777, 'RHESSI', /normal, charsize=1.2					
						
	legend, energies_legend[0:4], $
			color = colors[0:4], $
			linestyle = intarr(5), $
			box=0, $
			charsize=1.2, $
			pos = [0.12, 0.775], $
			/normal, $
			thick=3

	xyouts, 0.925, 0.77, 'b', /normal				

END

;********************
pro plot_fermi, date_start, date_end, plt_pos=plt_pos


	FermiGBM_file= '~/Data/2014_apr_18/fermi/fermi_ctime_n0_20140418_v00.sav'   

	restore, FermiGBM_file

	utplot, anytim(ut, /utim), binned[0,*], $
			/ylog, $
			yrange=[1.e-3, 1.e4], $
			position=plt_pos, $
			;/nolabel, $
			xtitle=' ', $
			XTICKFORMAT="(A1)", $
			/noerase, $
			timerange=[date_start, date_end], $
			ytitle='counts [s!u-1!n cm!u-2!n keV!u-1!n]', $
			/xs, $
			/ys, $
			color=6

	color=[6,3,4,0]
	for k=1,3 do outplot, anytim(ut, /utim), binned[k,*], col=color[k]
	outplot, anytim(ut, /utim), binned[3,*], col=10

	eband_str = string(eband[0,*], format='(f5.1)')

	legend, [eband_str[0]+' - '+eband_str[1]+' keV', $
			 eband_str[1]+' - '+eband_str[2]+' keV', $
			 eband_str[2]+' - '+eband_str[3]+' keV', $
			 eband_str[3]+' - '+eband_str[4]+' keV'  ], $
			color = [6,3,4,10], $
			linestyle = [0,0,0,0], $
			box=0, $
			charsize=0.6, $
			pos = [0.68, plt_pos[3]-0.012], $
			/normal, $
			thick=3

	xyouts, 0.7, plt_pos[3]-0.015, 'FERMI GBM', /normal, charsize=0.8, color=0

	;xyouts, 0.925, 0.58, 'c', /normal	

END

pro plot_fermi_zoom, date_start, date_end, plt_pos=plt_pos, $
	yrange=yrange, second_fermi=second_fermi, scale=scale, ylog=ylog, smoothing=smoothing


	FermiGBM_file= '~/Data/2014_apr_18/fermi/fermi_ctime_n0_20140418_v00.sav'   

	restore, FermiGBM_file
	ind0=3
	tims_ut = anytim(ut, /utim)
	flux = binned[ind0,*]
	flux = gauss_smooth(flux, smoothing)*scale
	;flux = flux/gauss_smooth(flux, 100)
	utplot, tims_ut, flux, $
			ylog=ylog, $
			yrange=yrange, $
			position=plt_pos, $
			;/nolabel, $
			xtitle=' ', $
			XTICKFORMAT="(A1)", $
			YTICKFORMAT="(A1)", $
			yticklen=-1e-5, $
			/noerase, $
			timerange=[date_start, date_end], $
			;ytitle='counts [s!u-1!n cm!u-2!n keV!u-1!n]', $
			ytitle=' ', $
			/xs, $
			/ys, $
			thick=4.5, $
			color=0
	outplot, tims_ut, flux, col=10, thick=3		


	ind1=2
	scaled_flux = gauss_smooth(binned[ind1,*]/9.0, smoothing)

	if keyword_set(second_fermi) then outplot, tims_ut, scaled_flux, col=4, thick=3
	
	if ~keyword_set(second_fermi) then begin
		plot, tims_ut, flux, /nodata, XTICKFORMAT="(A1)", YTICKFORMAT="(A1)", yticklen=-1, pos = [0.95, plt_pos[1], 0.951, plt_pos[3]], /normal, /noerase, color=10
		axis, yaxis=1, yr=yrange/scale, color=0, charsize=0.7, charthick=10, yticklen=-1e-1
		;axis, yaxis=1, yr=yrange/scale, color=10, charsize=0.8, yticklen=-1e-1
	endif	
	;outplot, tims_ut, flux, col=4, thick=2

	eband_str = string(eband[0,*], format='(f5.1)')

	;legend, [eband_str[2]+'-'+eband_str[3]+' keV', $
	;		 eband_str[3]+'-'+eband_str[4]+' keV'  ], $
	;		color = [10, 4] , $
	;		linestyle = [0,0], $
	;		box=0, $
	;		charsize=0.8, $
	;		pos = [0.7, plt_pos[3]-0.01], $
	;		/normal, $
	;		thick=3
END

;**********************************
;
;
;    	  Main procedure
;
;
;**********************************

pro plot_supp_fig8, postscript=postscript

	; For Figure 1 of the paper.

	;------------------------------------;
	;			Window params
	;
	loadct, 0
	reverse_ct
	cd,'~/Data/2014_apr_18/
	dam_folder = '~/Data/2014_apr_18/radio/dam/'
	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 10
	freq1 = 1000
	time0 = '20140418_124000'
	time1 = '20140418_131000'
	trange = anytim(file2time([time0, time1]), /utim)
	date_string = time2file(file2time(time0), /date)



	if keyword_set(postscript) then begin
		setup_ps, '~/supp_figure8.eps
	endif else begin	
		loadct, 0
		window, 10, xs=900, ys=1200, retain=2
		!p.charsize=1.0
		!p.color=255
		!p.background=0
	endelse			

		ypos = 0.98
		plot_delt = 0.13
		del_inc = 0.002
		pos0 = [0.1, ypos-plot_delt*2.0, 0.88, ypos]
		pos1 = [0.1, ypos-plot_delt*3.0, 0.88, ypos-plot_delt*2.0 - del_inc]
		pos2 = [0.1, ypos-plot_delt*4.0, 0.88, ypos-plot_delt*3.0- del_inc]
		pos3 = [0.1, ypos-plot_delt*5.0, 0.88, ypos-plot_delt*4.0- del_inc]
		pos4 = [0.1, ypos-plot_delt*6.3, 0.88, ypos-plot_delt*5.3- del_inc]
		;pos6 = [0.1, ypos-plot_delt*7.0, 0.93, ypos-plot_delt*6.0- del_inc]

		;***********************************;
		;			Plot GOES		
		;***********************************;
		set_line_color
		;plot_goes, time0, time1, plt_pos=pos0

		;***********************************;
		;			Plot RHESSI		
		;***********************************;

		;plot_RHESSI, time0, time1

		;***********************************;
		;			Plot FERMI		
		;***********************************;
		plot_fermi, trange[0], trange[1], plt_pos=pos1

		

		;***********************************;
		;	Read and pre-processed Orfees		
		;***********************************;	

		restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
		orf_spec = orfees_struct.spec
		orf_time = orfees_struct.time
		orf_freqs = orfees_struct.freq


		;***********************************;
		;	      Light-curves
		;***********************************;	
		set_line_color
		restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1_props_hires_si.sav', /verb	
		nrh_times = anytim(xy_arcs_struct.times, /utim)
		nrh_flux = xy_arcs_struct.flux_density
		ztime0 = '2014-04-18T12:40:00'
		ztime1 = '2014-04-18T13:10:00'
		ztrange = anytim([ztime0, ztime1], /utim)
		plot_fermi_zoom, ztrange[0], ztrange[1], yrange=[0.01, 0.3], plt_pos=pos2, /second_fermi, scale=1, ylog=1, smoothing=20
		plot_radio_flux, orf_spec, orf_time, orf_freqs, nrh_times, nrh_flux, ztrange, plt_pos=pos2, /long_duration, ylog=1, $
			yrange=[0.1, 1e3], smoothing=10, xtickfmt='(A1)', xtitle=' '
		

		plot_rstn, ztrange[0], ztrange[1], pos=pos3



		ztime0 = '2014-04-18T12:54:50'
		ztime1 = '2014-04-18T12:58:00'
		ztrange = anytim([ztime0, ztime1], /utim)
		
		plot_fermi_zoom, ztrange[0], ztrange[1], yrange=[0.05, 0.15], plt_pos=pos4, scale=1, ylog=0, smoothing=2
		plot_radio_flux, orf_spec, orf_time, orf_freqs, nrh_times, nrh_flux, ztrange, plt_pos=pos4, ylog=0, $
			yrange=[1, 220], smoothing=1, xtickfmt='', xtitle='Time (UT)'
		plot_rstn, ztrange[0], ztrange[1], pos=pos4, /oplot


		;***********************************;
		;			   PLOT
		;***********************************;
		cd, dam_folder
		read_dam, date_string, $
			dam_spec, dam_time, dam_freqs
		
		dam_spec = alog10(dam_spec)	
		dam_spec = constbacksub(dam_spec, /auto)
		dam_spec = dam_spec*3.0


		;***********************************;
		;	Read and pre-processed Orfees		
		;***********************************;	

		restore, orfees_folder+'orf_20140418_bsubbed_minimum_sfu.sav', /verb
		orf_spec = orf_spec/max(orf_spec)
		orf_spec = orf_spec*3.3  	; Scale arbitrarily so it fits 0-1 intensity range. Neater for colorbar
	

		plot_times = anytim(file2time([time0, time1]), /utim)

  		loadct, 74, /silent
		reverse_ct	

		plot_spec, dam_spec, dam_time, dam_freqs, [freq0, freq1], [time0, time1], scl0=0.0, scl1=1.0, plt_pos=pos0
		
		plot_spec, orf_spec, orf_time, orf_freqs, [freq0, freq1], [time0, time1], scl0=0.0, scl1=1.0, plt_pos=pos0

		loadct, 0
		utplot, plot_times, [freq1, freq0],	$
			/xs, $
			/ys, $
			/ylog, $
			/nodata, $
			ytitle='Frequency (MHz)', $
			xtitle=' ', $
			XTICKFORMAT="(A1)", $
			yr=[freq1, freq0 ], $
			xrange = plot_times, $
			/noerase, $
			position = pos0, $
			xticklen = -0.012, $
			yticklen = -0.015
	
		set_line_color
		xyouts, 0.115, pos0[3]-0.015, 'a', /normal, color=1, charthick=3	
		xyouts, 0.115, pos1[3]-0.015, 'b', /normal, color=0, charthick=3			
		xyouts, 0.115, pos2[3]-0.015, 'c', /normal, color=0, charthick=3			
		xyouts, 0.115, pos3[3]-0.015, 'd', /normal, color=0, charthick=3		
		xyouts, 0.115, pos4[3]-0.015, 'e', /normal, color=0, charthick=3		

		xyouts, 0.835, pos0[3]-0.11, 'NDA', /normal, color=1, charthick=3
		xyouts, 0.82, pos0[3]-0.25, 'Orfees', /normal, color=1, charthick=3		

	if keyword_set(postscript) then begin
		device, /close
		set_plot, 'x'
	endif

;	x2png,'dam_orfees_burst_20140418.png'
	

END

