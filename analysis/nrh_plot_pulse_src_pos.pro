pro nrh_plot_pulse_src_pos

	; Simple code to produce images of the pulsations source from 2014-04-18

	folder = '~/Data/2014_apr_18/pulsations/radio_nrh_hi_res/' 
	cd, folder
	filenames = findfile('*.fts')
	winsize=900
	window, 0, xs=winsize, ys=winsize, retain=2

	restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'

	!p.charsize=1.5	
	tstart = anytim('2014-04-18T12:54:30.000', /utim)	;anytim(file2time('20140418_125000'), /utim)	;anytim(file2time('20140418_125546'), /utim)	;anytim(file2time('20140418_125310'), /utim)
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

	restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src_props_hires_si.sav', /verb	
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
	for i=0, n_elements(xarcs)-1 do begin
		plots, xarcs[i], yarcs[i], psym=1, color=colors[i], symsize=0.8, thick=2
		;wait, 0.1
	endfor	

STOP
END