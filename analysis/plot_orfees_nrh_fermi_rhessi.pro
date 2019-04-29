pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=0.8
  !p.thick=4
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=8, $
          ysize=12, $
          /encapsulate, $
          yoffset=5

end


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

pro plot_goes, t0, t1, plt_pos=plt_pos

		x1 = t0 ;anytim(file2time(t1), /utim)
		x2 = t1 ;anytim(file2time(t2), /utim)
		
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

	t0_rhessi = anytim(t0, /atimes)
	t1_rhessi = anytim(t1, /atimes)

	obj = hsi_obs_summary()
	obj -> set, obs_time_interval=[t0_rhessi, t1_rhessi]
	d1 = obj -> getdata()
	data = d1.countrate
	times_rate = obj -> getaxis(/ut) 

	set_line_color
	plot_indeces = where(times_rate gt anytim('2014-04-18T12:50:00', /utim))

	utplot, times_rate[plot_indeces], smooth(data[4, plot_indeces],5), $
			thick=5, $
			/xs, $ 
			/ys, $
			/ylog, $
			;psym=4, $
			xr=anytim([file2time(t0), file2time(t1)], /utim), $
			yr = [1, 1e4], $
			XTICKFORMAT="(A1)", $
			xtitle=' ', $
			ytitle='Count Rate (s!U-1!N detector!U-1!N)', $
			color=5, $
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
					

	xyouts, 0.14, plt_pos[3]-0.128, 'RHESSI', /normal, charsize=1.2					
						
	legend, energies_legend[0:4], $
			color = colors[0:4], $
			linestyle = intarr(5), $
			box=0, $
			charsize=0.8, $
			pos = [0.12,  plt_pos[3]-0.13], $
			/normal, $
			thick=3

	xyouts, 0.925, plt_pos[3]-0.12, 'b', /normal				

END

;********************
pro plot_fermi, date_start, date_end, plt_pos=plt_pos


	FermiGBM_file= '~/Data/2014_apr_18/fermi/fermi_ctime_n0_20140418_v00.sav'   

	restore, FermiGBM_file
	color = [6,3,4,10]
	ind0=3
	tims_ut = anytim(ut, /utim)
	flux = binned[ind0,*]
	flux = gauss_smooth(flux, 5)
	;flux = flux/gauss_smooth(flux, 100)
	utplot, tims_ut, flux, $
			;/ylog, $
			yrange=[0.02, 0.25], $
			position=plt_pos, $
			;/nolabel, $
			xtitle=' ', $
			XTICKFORMAT="(A1)", $
			YTICKFORMAT="(A1)", $
			/noerase, $
			timerange=[date_start, date_end], $
			;ytitle='counts [s!u-1!n cm!u-2!n keV!u-1!n]', $
			ytitle=' ', $
			/xs, $
			/ys, $
			thick=2, $
			color=color[ind0]

	;for k=1,3 do 
	outplot, anytim(ut, /utim), gauss_smooth(binned[2,*]/10.0, 5), col=4
	stop
	eband_str = string(eband[0,*], format='(f5.1)')

	legend, [eband_str[0]+'-'+eband_str[1]+' keV', $
			 eband_str[1]+'-'+eband_str[2]+' keV', $
			 eband_str[2]+'-'+eband_str[3]+' keV', $
			 eband_str[3]+'-'+eband_str[4]+' keV'  ], $
			color = color, $
			linestyle = [0,0,0,0], $
			box=0, $
			charsize=0.8, $
			pos = [0.12, plt_pos[3]-0.13], $
			/normal, $
			thick=3

	xyouts, 0.135, plt_pos[3]-0.128, 'FERMI GBM', /normal, charsize=1.2

	xyouts, 0.925, 0.58, 'c', /normal	
	stop

END

pro plot_orfees_nrh_fermi_rhessi, postscript=postscript

	; Window setup
	if keyword_set(postscript) then begin
        setup_ps, '~/Data/2014_apr_18/pulsations/orfees_nrh_flux.eps
	endif else begin
		loadct, 0
		!p.thick=1
		!p.background=70
		window, 0, xs=900, ys=1300, retain=2
	endelse

	;-------------------------------------------;
	;	 Plot Stokes I NRH source properties
	;	
	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	temp = xy_arcs_struct.Tb
	flux = xy_arcs_struct.flux_density
	sizes = xy_arcs_struct.poor_src_sizes
	gauss_params = xy_arcs_struct.gauss_params
	sizes = !pi*gauss_params[2, *]*gauss_params[3, *]
	xarcs = xy_arcs_struct.x_max_fit
	yarcs = xy_arcs_struct.y_max_fit
	pos_vector = sqrt(xarcs^2.0 + yarcs^2.0)

	set_line_color
	ypos = 0.98
	plot_delt = 0.20
	del_inc = 0.002
	pos0 = [0.1, ypos-plot_delt, 0.93, ypos]
	pos1 = [0.1, ypos-plot_delt*2.0, 0.93, ypos-plot_delt - del_inc]
	pos2 = [0.1, ypos-plot_delt*3.0, 0.93, ypos-plot_delt*2.0- del_inc]
	pos3 = [0.1, ypos-plot_delt*4.0, 0.93, ypos-plot_delt*3.0- del_inc]
	pos4 = [0.1, ypos-plot_delt*5.0, 0.93, ypos-plot_delt*4.0- del_inc]
	pos5 = [0.1, ypos-plot_delt*6.0, 0.93, ypos-plot_delt*5.0- del_inc]
	pos6 = [0.1, ypos-plot_delt*7.0, 0.93, ypos-plot_delt*6.0- del_inc]
	;pos6 = [0.1, ypos-plot_delt*6.0, 0.95, ypos-plot_delt*6.0]

	;-----------------------------------;
	;			Plot Orfees 
	;
	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 180
	freq1 = 270
	time0 = '2014-04-18T12:50:00'
	time1 = '2014-04-18T13:00:00'
	trange = anytim([time0, time1], /utim)
	date_string = time2file(time0, /date)

	restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = orfees_struct.freq

	freq_array = reverse(orf_freqs)
	index = closest(freq_array, 208)
	lcurve = orf_spec[*, index]
	utplot, orf_time, lcurve, $
		/xs, $
		/ys, $
		;/ylog, $
		linestyle = 0, $
		color = 1, $
		xticklen=-1e-5, $
		yticklen=-1e-5, $
		ytitle = ' ', $
		xtitle = ' ', $
		thick=1, $
		ytickformat='(A1)', $
		xtickformat='(A1)', $
		position = pos3, $
		xr = trange, $
		yr=[0.3, 1.3], $
		/normal, $
		/noerase

	set_line_color
	utplot, times, flux, $  ; NRH flux
		/xs, $
		/ys, $
		;/ylog, $
		ytitle='Flux (SFU)', $
		;xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = 'Time UT', $
  		yr=[10, 220], $
		position = pos3, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=6		

	;***********************************;
	;			Plot GOES		
	;***********************************;
	set_line_color
	plot_goes, trange[0],  trange[1], plt_pos=pos0

	;***********************************;
	;			Plot RHESSI		
	;***********************************;

	plot_RHESSI, trange[0],  trange[1], plt_pos=pos1

	;***********************************;
	;			Plot FERMI		
	;***********************************;
	plot_fermi, trange[0],  trange[1], plt_pos=pos3



if keyword_set(postscript) then device, /close
set_plot, 'x'

END