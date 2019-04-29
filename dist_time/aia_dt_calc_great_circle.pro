pro aia_dt_calc_great_circle, hot=hot
	
	; Same as aia_dt_calc but this time produces profiles from great circles.
	; Great circle pixels produced from aia_gcircle_20140418

	; Code to produce distance time map from line on AIA image
	; These maps are then used in the three colour map code aia_dt_plot_three_color.pro

	loadct, 1
	!p.charsize=1.5
	winsz=500
	AU = 1.49e11	; meters
	if keyword_set(hot) then aia_waves = ['094A', '131A', '335A'] else aia_waves = ['171A', '193A', '211A']	;['094A', '131A', '335A']	;['171A', '193A', '211A']  ; ['094A', '131A', '335A']	
	npoints = 800	; Max index of the great circle to go up to. They won't go up to the limb
	window, 0, xs=winsz, ys=winsz, retain = 2
	window, 4, xs=winsz, ys=winsz, retain = 2
	window, 3, xs=500, ys=500, xpos=1900, ypos=100


	gcircles_file = '~/Data/2014_apr_18/sdo/dist_time/great_circles/xy_gcircle_arcs_20140418_south.sav'
	restore, gcircles_file, /verbose
	arc_numbers=(tag_names(xy_pixel_profs))[where(strmid(tag_names( xy_pixel_profs), 0, 5) eq 'XYPIX')]


	for k=0, n_elements(aia_waves)-1 do begin
		;-------------------------------------------------;
		;		  Choose files unaffected by AEC
		;
		folder = '~/Data/2014_Apr_18/sdo/'+aia_waves[k]+'/'
		aia_files = findfile(folder+'aia*.fits')
		mreadfits_header, aia_files, ind, only_tags='exptime'
		f = aia_files[where(ind.exptime gt 1.)]
		
		mreadfits_header, f, ind
		start = closest(anytim(ind.date_obs, /utim), anytim('2014-04-18T12:30:00', /utim))
		finish = closest(anytim(ind.date_obs, /utim), anytim('2014-04-18T13:15:00', /utim))
		distt = fltarr(1+(finish - start), npoints)

		tstart = anytim( (ind.date_obs)[start], /utim)
		tend = anytim( (ind.date_obs)[finish], /utim)
		tarr = anytim( (ind.date_obs)[start:finish], /utim) 	;( findgen(finish-start)*(tend - tstart)/(finish-start -1) ) + tstart

		;----------------------------------------------------;
		;		Define lines over which to interpolate
		;
		read_sdo, f[0], $
			he_dummy, $
			data_dummy

		index2map, he_dummy, $
			smooth(data_dummy, 7)/he_dummy.exptime, $
			map_dummy, $
			outsize = 4096

		axis1_sz = (size(map_dummy.data))[1]/2.0	
		axis2_sz = (size(map_dummy.data))[2]/2.0
		fnpoints = findgen(npoints)

		WAVEL = string(he_dummy.WAVELNTH, format = '(I03)')
	  
	  	FOR i = start, finish DO BEGIN ;n_elements(f)-2 DO BEGIN

			;-------------------------------------------------;
			;			 		Read data
			; 
			; The actual dt_plotter takes care of the differencing now. See aia_dt_plot_three_color.
			read_sdo, f[i], $ 
				he_aia, $
				data_aia

			data_aia = data_aia/he_aia.exptime
			wset, 4
			loadct, 1, /silent
			plot_image, sigrange(data_aia)

			;index2map, he_aia, $
			;	smooth(data_aia, 7)/he_aia.exptime, $
			;	map, $
			;	outsize = 4096

			;undefine, data_aia
			
			;wset, 4
			;loadct, 1, /silent
			;plot_map, map, $
			;	dmin = -25, $
			;	dmax = 800, $
			;	fov = FOV,$
			;	center = CENTER

			set_line_color	
			for q=0, n_elements(arc_numbers)-1 do begin
				arc_number = arc_numbers[q]
				xypos = XY_PIXEL_PROFS.(where(tag_names(XY_PIXEL_PROFS) eq arc_number))
				azim = xy_pixel_profs.(where(tag_names(XY_PIXEL_PROFS) eq arc_number)+1)
				azim = azim[0:npoints-1]
				pixx = xypos[0, 0:npoints-1]
				pixy = xypos[1, 0:npoints-1]
				lindMm = (azim - azim[0])*!dtor*695.0
				xlin = (pixx - axis1_sz)*he_dummy.cdelt1
				ylin = (pixy - axis2_sz)*he_dummy.cdelt2

				ind120Mm = closest(lindMm, 100)
				ind220Mm = closest(lindMm, 200)
				ind320Mm = closest(lindMm, 300)
				ind420Mm = closest(lindMm, 400)

				plots, pixx, pixy, /data, color=3, thick=1.5
				plots, pixx[ind120Mm], pixy[ind120Mm], /data, color=3, thick=1.5, psym=1
				plots, pixx[ind220Mm], pixy[ind220Mm], /data, color=3, thick=1.5, psym=1
				plots, pixx[ind320Mm], pixy[ind320Mm], /data, color=3, thick=1.5, psym=1
				plots, pixx[ind420Mm], pixy[ind420Mm], /data, color=3, thick=1.5, psym=1

				intns_prof = smooth(transpose(interpolate(data_aia, pixx, pixy)), 10)

				if q eq 0 then profiles = [intns_prof] else profiles = [ [profiles], [intns_prof] ]

			endfor
			;STOP
			if (size(profiles))[0] gt 1 then prof = total( profiles, 2 ) else prof=profiles
			distt[i-start, *] = prof
			
			loadct, 1, /silent
			wset, 3
			spectro_plot, sigrange(distt), tarr, lindMm, $
							/xs, $
							/ys, $
							ytitle='Distance (Mm)'

			;print, anytim(tarr[i-start], /yoh), ' and '+he_aia.date_obs
			progress_percent, i, start, finish-1
			;stop
		ENDFOR
		dt_map_struct = {name:'dt_map_'+WAVEL, arc_numbers:arc_numbers, dtmap:distt, time:tarr, distance:lindMm, xyarcsec:[ xlin, ylin ] }
	  	save, dt_map_struct, $
	  		filename='~/Data/2014_apr_18/sdo/dist_time/great_circles/aia_'+WAVEL+'_dt_map_gcircle_south.sav'	
	endfor		

	;aia_dtplot_gcircle_three_color, /rratio
	STOP

END