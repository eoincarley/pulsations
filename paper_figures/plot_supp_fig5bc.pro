pro plot_supp_fig5bc

	; Adapted from nrh_QPratio_displacement.pro

	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	xarcs = xy_arcs_struct.x_max_fit
	yarcs = xy_arcs_struct.y_max_fit
	mean_x = mean(xarcs)
	mean_y = mean(yarcs)
	smoothing=1


	xarcs = smooth(xarcs, smoothing)
	yarcs = smooth(yarcs, smoothing)
	plotsym, 0, /fill
	displacement = fltarr(n_elements(xarcs)-1)

	for i=1, n_elements(xarcs)-1 do displacement[i-1] = xarcs[i] - xarcs[0]
	

	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1left_props_hires_si.sav', /verb	
	Pflux = smooth(xy_arcs_struct.FLUX_DENSITY, smoothing)
	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1right_props_hires_si.sav', /verb	
	Qflux = smooth(xy_arcs_struct.FLUX_DENSITY, smoothing)
	times = xy_arcs_struct.TIMES

	set_line_color
	if keyword_set(postscript) then begin
		setup_ps, '~/QP_ratio_displ2.eps'
	endif else begin
		window, 1, xs=1800, ys=400
	endelse
	times = anytim(times, /utim)

	tstart = anytim('2014-04-18T12:55:00.000', /utim)	;anytim(file2time('20140418_125000'), /utim)	;anytim(file2time('20140418_125546'), /utim)	;anytim(file2time('20140418_125310'), /utim)
	tstop =  anytim('2014-04-18T12:55:40.000', /utim)   ;anytim(

	qp_ratio = Qflux/Pflux
	utplot, times, qp_ratio, /xs, /ys, ytitle=' ', $
		pos=[0.1, 0.17, 0.9, 0.92], $
		yr=[0,8], $
		color=0, $
		/nodata, $
		xtitle='Time (UT)', $
		ytickformat="(A1)", $
		yticklen=-1e-5, $
		xticklen = 1.0, xgridstyle = 1.0, $
		xr=[tstart, tstop]

	loadct, 61
	outplot, times, qp_ratio, color=110, thick=2
	loadct, 62
	outplot, times, qp_ratio, color=120
	axis, yaxis=0, yr=[0,8], ytitle='Q/P flux ratio', color=120


	set_line_color
	times = times[1:n_elements(times)-1]
	displ = displacement*0.727

	utplot, times, displ, $
		pos=[0.1, 0.17, 0.9, 0.92], /noerase, $
		yr=[-200, 0], $
		/ys, $
		/xs, $
		ytitle='  ', $
		ytickformat="(A1)", $
		xtickformat="(A1)", $
		xtitle=' ', $
		xticklen=-1e-5, $
		yticklen=-1e-5, $
		color=2, $
		/nodata, $
		xr=[tstart, tstop]

	loadct, 0
	outplot, times, displ, color=120
	;outplot, times, replicate(-40, n_elements(times)), color=140, thick=0.5
	;outplot, times, replicate(-1170, n_elements(times)), color=140, thick=0.5
	axis, yaxis=1, /ys, yr=[-200, 0], ytitle='Source displacement (Mm)'
	if keyword_set(postscript) then device, /close
	set_plot, 'x'


STOP
END