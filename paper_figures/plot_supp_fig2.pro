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
          ysize=4, $
          /encapsulate, $
          yoffset=5

end

pro plot_fluxes_seperate, freq, trange, pos

	;---------------------------------------------------;
	;
	;	 Plot flux for 228 MHz left and right sources
	;	
	freq_string = string(freq, format='(I3)')
	restore, '~/Data/2014_apr_18/pulsations/nrh_'+freq_string+'_pulse_src1left_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	temp0 = xy_arcs_struct.Tb
	flux0 = xy_arcs_struct.flux_density

	restore, '~/Data/2014_apr_18/pulsations/nrh_'+freq_string+'_pulse_src1right_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	temp1 = xy_arcs_struct.Tb
	flux1 = xy_arcs_struct.flux_density

	utplot, times, flux0, $
		/xs, $
		/ys, $
		/ylog, $
		ytitle='Flux (SFU)', $
		xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = ' ', $
  		yr=[1, 150], $
		position = pos, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=3

	loadct, 3
	outplot, times, flux1, color=240, linestyle=0




END

pro plot_fluxes, freq, trange, pos, xaxis=xaxis, color=color

	;---------------------------------------------------;
	;
	;	 Plot flux for 228 MHz left and right sources
	;	
	freq_string = string(freq, format='(I3)')
	restore, '~/Data/2014_apr_18/pulsations/nrh_'+freq_string+'_pulse_src1_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	temp0 = xy_arcs_struct.Tb
	flux0 = xy_arcs_struct.flux_density

	if keyword_set(xaxis) then xaxis = '' else xaxis = '(A1)'
	utplot, times, flux0, $
		/xs, $
		/ys, $
		/ylog, $
		ytitle='Flux (SFU)', $
		xtickformat=xaxis, $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = ' ', $
  		yr=[1, 150], $
		position = pos, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=color

	;outplot, times, flux1, color=4


END

pro plot_supp_fig2, postscript=postscript

	; Rearrange these plots to create supplementary figure 2

	; Window setup
	if keyword_set(postscript) then begin
        setup_ps, '~/Data/2014_apr_18/pulsations/nrh_pulse_src_separate.eps
	endif else begin
		loadct, 0
		!p.background=70
		window, 0, xs=1700, ys=600, retain=2
	endelse

	set_line_color
	ypos = 0.98
	plot_delt = 0.45
	del_inc = 0.006
	pos0 = [0.1, ypos-plot_delt, 0.93, ypos]
	pos1 = [0.1, ypos-plot_delt*2.0, 0.93, ypos-plot_delt - del_inc]
	pos2 = [0.1, ypos-plot_delt*3.0, 0.93, ypos-plot_delt*2.0- del_inc]
	;pos3 = [0.1, ypos-plot_delt*4.0, 0.93, ypos-plot_delt*3.0- del_inc]
	;pos4 = [0.1, ypos-plot_delt*5.0, 0.93, ypos-plot_delt*4.0- del_inc]
	;pos5 = [0.1, ypos-plot_delt*6.0, 0.93, ypos-plot_delt*5.0- del_inc]
	;pos6 = [0.1, ypos-plot_delt*7.0, 0.93, ypos-plot_delt*6.0- del_inc]
	;pos6 = [0.1, ypos-plot_delt*6.0, 0.95, ypos-plot_delt*6.0]

	time0 = '2014-04-18T12:56:00'
	time1 = '2014-04-18T12:57:00'
	trange = anytim([time0, time1], /utim)
	plot_fluxes_seperate, 228, trange, pos0
	set_line_color
	plot_fluxes, 298, trange, pos1, color=4
	plot_fluxes, 327, trange, pos1, /xaxis, color=5

	loadct, 0
	restore, '~/Data/2014_apr_18/pulsations/nrh_408_pulse_src1_flux_hires_si.sav'
	times = anytim(flux_struct.times, /utim)
	flux = smooth(flux_struct.flux_density, 5)
	outplot, times, flux, color=100

	restore, '~/Data/2014_apr_18/pulsations/nrh_432_pulse_src1_flux_hires_si.sav'
	times = anytim(flux_struct.times, /utim)
	flux = smooth(flux_struct.flux_density, 5)
	outplot, times, flux, color=150

	restore, '~/Data/2014_apr_18/pulsations/nrh_445_pulse_src1_flux_hires_si.sav'
	times = anytim(flux_struct.times, /utim)
	flux = smooth(flux_struct.flux_density, 5)
	outplot, times, flux, color=200



	;-----------------------------------;
	;			Plot Orfees 
	;
	freq = 208
	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 180
	freq1 = 270
	date_string = time2file(time0, /date)

	restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = orfees_struct.freq

	freq_array = reverse(orf_freqs)
	index = closest(freq_array, freq)
	lcurve = orf_spec[*, index]

	;utplot, orf_time, lcurve, $
	;	/xs, $
	;	/ys, $
		;/ylog, $
	;	linestyle = 0, $
	;	color = 1, $
	;	xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
	;	ytitle = ' ', $
	;	xtickformat='(A1)', $
	;	ytickformat='(A1)', $
  	;	xtitle = ' ', $
	;	position = pos0, $
	;	xr = trange, $
	;	yr=[0.1, 1.5], $
	;	/normal, $
	;	/noerase

	if keyword_set(postscript) then device, /close 
	set_plot, 'x'


stop
END