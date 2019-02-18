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

pro plot_figure2c, postscript=postscript

	; Window setup
	if keyword_set(postscript) then begin
        setup_ps, '~/Data/2014_apr_18/pulsations/orfees_nrh_flux.eps
	endif else begin
		window, 0, xs=800, ys=1300, retain=2
		 !p.thick=1
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
	plot_delt = 0.13
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
	time0 = '2014-04-18T12:54:00'
	time1 = '2014-04-18T12:57:40'
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
		position = pos0, $
		xr = trange, $
		yr=[0.3, 1.3], $
		/normal, $
		/noerase

	set_line_color
	utplot, times, flux, $
		/xs, $
		/ys, $
		;/ylog, $
		ytitle='Flux (SFU)', $
		;xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = 'Time UT', $
  		yr=[10, 220], $
		position = pos0, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=6		



if keyword_set(postscript) then device, /close
set_plot, 'x'
STOP

	utplot, times, temp, $
		/xs, $
		/ys, $
		ytitle='Brightness Temperature (K)', $
		xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = ' ', $
  		yr=[3e7, 1.2e9], $
		position = pos1, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=3


	utplot, orf_time, lcurve, $
		/xs, $
		/ys, $
		linestyle = 0, $
		color = 1, $
		xticklen=-1e-5, $
		yticklen=-1e-5, $
		ytitle = ' ', $
		xtitle = ' ', $
		ytickformat='(A1)', $
		xtickformat='(A1)', $
		position = pos1, $
		xr = trange, $
		yr=[0.4, 1.3], $
		/normal, $
		/noerase	

STOP		

	utplot, times, flux, $
		/xs, $
		/ys, $
		ytitle='Flux (SFU)', $
		;xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = 'Time UT', $
  		yr=[40, 200], $
		position = pos2, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=6	

stop
	;-------------------------------------------;
	;	 Plot Stokes I NRH source properties
	


stop
END