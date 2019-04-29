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

pro plot_supp_fig3, postscript=postscript

	; Rearrange these plots to create supplementary figure 2

	; Window setup
	if keyword_set(postscript) then begin
        setup_ps, '~/Data/2014_apr_18/pulsations/nrh_pulse_src_props_v2.eps
	endif else begin
		window, 0, xs=800, ys=1300, retain=2
	endelse

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
	time0 = '2014-04-18T12:54:50'
	time1 = '2014-04-18T12:55:50'
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
		linestyle = 0, $
		color = 0, $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
		ytitle = 'Intensity (arbitrary)', $
		xtickformat='(A1)', $
  		xtitle = ' ', $
		position = pos0, $
		xr = trange, $
		yr=[0.7, 1.2], $
		/normal, $
		/noerase


	;-------------------------------------------;
	;	 Plot Stokes I NRH source properties
	;	
	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	temp = xy_arcs_struct.Tb
	flux = xy_arcs_struct.flux_density
	sizes = xy_arcs_struct.poor_src_sizes
	gauss_params = xy_arcs_struct.gauss_params
	sizes = !pi*gauss_params[2, *]*gauss_params[3, *]
	xarcs = xy_arcs_struct.x_max_fit
	yarcs = xy_arcs_struct.y_max_fit
	pos_vector = sqrt(xarcs^2.0 + yarcs^2.0)


	pos_vector = pos_vector*727.0	; km
	mean_pos = mean(pos_vector)
	amplitude = pos_vector - mean_pos

	utplot, times, smooth(amplitude, 2), $
		/xs, $
		/ys, $
		ytitle='Displacement (km)', $
		xtickformat='(A1)', $
		xtitle = ' ', $
		;/ylog, $
		;yr=[1.8e5, 2.2e5], $
		;yr = [min(pos_vector), 2.5e5], $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
		position = pos1, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=6	

	times_sec = times - times[0]
	speed = deriv(times_sec, pos_vector)

	utplot, times, smooth(abs(speed), 2)/2.9e5, $
		/xs, $
		/ys, $
		;ytitle=' ', $
		xtitle='Time (UT)', $
		xticklen = 1.0, xgridstyle = 1.0, $
		;ytickformat='(A1)', $
		;yticklen=-1e-5, $
		ytitle='Speed (c)', $
		yr = [1e-3, 0.2], $
		/ylog, $
		position = pos2, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=7	

	;axis, yaxis=0, yr=[1000.0, 1e5], /ylog, yticklen = 1.0, ygridstyle = 1.0, ytitle='Speed (km/s)'
	;axis, yaxis=1, yr=[1000.0/2.9e5, 1e5/2.9e5], ytitle='Speed (c)'
	loadct, 0	
	plotlinsy = [1e-3*findgen(10), 1e-2*findgen(10), 1e-1*findgen(10)]
	for i=1, n_elements(plotlinsy)-1 do outplot, [times[0], times[n_elements(times)-1]], [plotlinsy[i], plotlinsy[i]], color=140, linestyle=0, thick=0.5
	set_line_color
	outplot, times, smooth(abs(speed), 2)/2.9e5, color=7

if keyword_set(postscript) then device, /close
set_plot, 'x'

STOP
;********************************************************************************;		

	utplot, times, temp, $
		/xs, $
		/ys, $
		ytitle='Brightness Temperature (K)', $
		xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = ' ', $
  		yr=[3e8, 1.2e9], $
		position = pos1, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=3

	utplot, times, flux, $
		/xs, $
		/ys, $
		ytitle='Flux (SFU)', $
		xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = ' ', $
  		yr=[40, 200], $
		position = pos2, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=6

	utplot, times, sizes, $
		/xs, $
		/ys, $
		yr=[40, 90], $
		ytitle='Size (pixels^2)', $
		xtickformat='(A1)', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
  		xtitle = ' ', $
  		;yr=[4.8e8, 1e9], $
		position = pos4, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=7	



	;-------------------------------------------;
	;	 Plot Stokes I NRH source properties
	;	
	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src_props_hires_sv.sav', /verb	
	;times = anytim(xy_arcs_struct.times, /utim)
	V_temp = xy_arcs_struct.Tb
	V_flux = xy_arcs_struct.flux_density
	V_sizes = xy_arcs_struct.poor_src_sizes
	V_xarcs = xy_arcs_struct.x_max_fit
	V_yarcs = xy_arcs_struct.y_max_fit
	V_pos_vector = sqrt(xarcs^2.0 + yarcs^2.0)	

	polari = (V_flux/flux)*100.0

	utplot, times, smooth(polari, 2), $
		/xs, $
		/ys, $
		yr = [-70, -40], $
		ytitle='Polarisation (%)', $
		xtickformat='(A1)', $
  		xtitle = ' ', $
		xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
		position = pos3, $
		xr = trange, $
		/normal, $
		/noerase, $
		color=5
		

stop
END