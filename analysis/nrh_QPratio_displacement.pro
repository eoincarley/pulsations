pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=1.1
  !p.thick=4
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=8, $
          ysize=2.8, $
          /encapsulate, $
          yoffset=5

end

pro nrh_QPratio_displacement, postscript=postscript

	; Simple code to produce images of the pulsations source from 2014-04-18

	folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/' 
	cd, folder
	filenames = findfile('*.fts')
	winsize=900
	window, 0, xs=winsize, ys=winsize, retain=2

	restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'

	!p.charsize=1.5	
	tstart = anytim('2014-04-18T12:55:30.000', /utim)	;anytim(file2time('20140418_125000'), /utim)	;anytim(file2time('20140418_125546'), /utim)	;anytim(file2time('20140418_125310'), /utim)
	tstop =  anytim('2014-04-18T12:57:30.000', /utim)    ;anytim(file2time('20740418_125440'), /utim)	;anytim(file2time('20140418_125650'), /utim)		;anytim(file2time('20140418_125440'), /utim) 
	FOV = [5, 5]
	CENTER = [0.0, -300.0]


	t0str = anytim(tstart, /yoh, /time_only)
	t1str = anytim(tstop, /yoh, /time_only)

	read_nrh, filenames[2], $
			  nrh_hdrs, $
			  nrh_data_cube, $
			  hbeg=t0str, $ 
			  hend=t1str


	freq = nrh_hdrs[0].FREQ

	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src1_props_hires_si.sav', /verb	
	times = anytim(xy_arcs_struct.times, /utim)
	xarcs = xy_arcs_struct.x_max_fit
	yarcs = xy_arcs_struct.y_max_fit
	mean_x = mean(xarcs)
	mean_y = mean(yarcs)
  
		
	nrh_hdr = nrh_hdrs[0]
	nrh_data = nrh_data_cube[*, *, 0]
	index2map, nrh_hdr, nrh_data, $
			   nrh_map  
	nrh_time = nrh_hdr.date_obs
			
	;------------------------------------;
	;			Plot Total I
	loadct, 26, /silent
	plot_map, nrh_map, $
		fov = FOV, $
		center = CENTER, $
		dmin = 1e9, $
		dmax = 1e10, $
		title='NRH '+string(freq, format='(I03)')+' MHz '+ $
		string( anytim( nrh_time, /yoh) )+' UT', $
		;position=[0.05, 0.15, 0.36, 0.85], $
		/normal

	set_line_color
	plot_helio, nrh_time, $
		/over, $
		gstyle=1, $
		gthick=1.0, $
		gcolor=4, $
		grid_spacing=15.0
								   

	for i=0, n_elements(xlines_total)-1 do begin
		;plots, xlines, ylines, col=0, thick=8
		xlines = XLINES_TOTAL[i]
		ylines = YLINES_TOTAL[i]
     	plots, xlines>(-150)<150, ylines>(-450)<(-150), col=10, thick=0.5
    endfor 	
	
	loadct, 74, /silent
	colors = findgen(n_elements(xarcs))*(255)/(n_elements(xarcs)-1)

	smoothing=1

	xarcs = smooth(xarcs, smoothing)
	yarcs = smooth(yarcs, smoothing)
	plotsym, 0, /fill
	displacement = fltarr(n_elements(xarcs)-1)

	for i=1, n_elements(xarcs)-1 do begin
		;print, anytim(times[i], /cc)
		plots, xarcs[i], yarcs[i], psym=8, color=250, symsize=2.0, thick=1
		plots, xarcs[i], yarcs[i], psym=8, color=colors[i], symsize=1.8, thick=2

		displacement[i-1] = xarcs[i] - xarcs[0]
		;wait, 0.1
	endfor	


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
	tstop =  anytim('2014-04-18T12:55:40.000', /utim)    ;anytim(

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