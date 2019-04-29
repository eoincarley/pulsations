pro aia_dt_calc_pulsations_v2

	; Code to produce distance time map of pulsations from line on AIA image on 2014-04-18
	; These maps are then used in the three colour map code aia_dt_plot_three_color.pro

	; v2 Get dt trace along radio pulsation source trajectory.

	loadct, 1
	!p.charsize=1.5
	winsz=1100
	AU = 1.49e11	; meters
	aia_waves = ['094A', '131A', '335A']
	angles = [250.0]
	npoints = 4000
	radius = 240	;arcsec
	x1 = -50.0
	y1 = -130.0
	FOV = [5.0, 5.0]
	CENTER = [-100.0, -250.0]

	for k=2, n_elements(aia_waves)-1 do begin
		;-------------------------------------------------;
		;
		;		  Choose files unaffected by AEC
		;
		folder = '~/Data/2014_Apr_18/sdo/'+aia_waves[k]+'/'
		aia_files = findfile(folder+'aia*.fits')
		mreadfits_header, aia_files, ind, only_tags='exptime'
		f = aia_files[where(ind.exptime gt 1.)]

		;window, 0, xs=winsz, ys=winsz, retain = 2, xpos=1900, ypos=1000
		window, 0, xs=winsz, ys=winsz, retain = 2;, xpos=1900, ypos=1000
		window, 1, xs=500, ys=500;, xpos=1900, ypos=100
		
		mreadfits_header, f, ind
		start = closest(anytim(ind.date_obs, /utim), anytim('2014-04-18T12:45:00', /utim))
		finish = closest(anytim(ind.date_obs, /utim), anytim('2014-04-18T13:30:00', /utim))
		distt = fltarr(1+(finish - start), npoints)

		tstart = anytim( (ind.date_obs)[start], /utim)
		tend = anytim( (ind.date_obs)[finish], /utim)
		tarr = anytim( (ind.date_obs)[start:finish], /utim) 	;( findgen(finish-start)*(tend - tstart)/(finish-start -1) ) + tstart

		;----------------------------------------------------;
		;
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

		for j = 0, n_elements(angles)-1 do begin
			
			angle = angles[j]
			x2 = x1 + radius*cos(angle*!dtor)	;808.0	
			y2 = y1 + radius*sin(angle*!dtor)	;-120.0
			xlin = ( fnpoints*(x2 - x1)/(npoints-1) ) + x1
			ylin = ( fnpoints*(y2 - y1)/(npoints-1) ) + y1	

			;---------------------------------------------------------;
			;				Same lines on data array
			;
			pixx = FIX( axis1_sz + xlin/map_dummy.dx )
			pixy = FIX( axis2_sz + ylin/map_dummy.dy )

			;---------------------------------------------------------;
			;				Line length in arcsecs
			;
			lina = sqrt( (x2-x1)^2.0 + (y2-y1)^2.0 )
			lind = AU*tan((lina/3600.0)*!dtor)/1e6
			lindMm = fnpoints*(lind)/(npoints-1.0)

			WAVEL = string(he_dummy.WAVELNTH, format = '(I03)')
		  
		  	FOR i = start, finish DO BEGIN ;n_elements(f)-2 DO BEGIN

				;-------------------------------------------------;
				;			 		Read data
				; 
				; The actual dt_plotter takes care of the differencing now. See aia_dt_plot_three_color.
				loadct, 0, /silent
				;read_sdo, f[i], $ 
				;	he_aia, $
				;	data_aia

				aia_prep, f[i], -1, he_aia, iscaled_img, /uncomp_delete, /norm	

				iscaled_img = ( iscaled_img - mean(iscaled_img) ) /stdev(iscaled_img)   
	           ; hfreq = iscaled_img - smooth(iscaled_img, 3)
	            ;iscaled_img = 0.3*iscaled_img + 2.5*hfreq
	            iscaled_img = iscaled_img > (-0.5) < 4  ; -1, 6 	

				index2map, he_aia, $
					iscaled_img, $
					map, $
					outsize = 4096

				;undefine, data_aia
				wset, 0
			
				plot_map, map, $
					;dmin = -25, $
					;dmax = 800, $
					fov = FOV,$
					center = CENTER

				;x2png, '~/Data/2014_apr_18/pulsations/image_'+string(i-start, format='(I04)' )+'.png'					
				
				;plot_helio, he_aia.date_obs, $
				;	/over, $
				;	gstyle=0, $
				;	gthick=1.0, $	
				;	gcolor=255, $
				;	grid_spacing=15.0

				;nrh_oplot_pulse_src_pos
				;set_line_color
				plots, xlin, ylin, /data, color=0, thick=2.5
				plots, xlin+3.0, ylin, /data, color=3, thick=1.5
				plots, xlin+6.0, ylin, /data, color=3, thick=1.5
				plots, xlin+9.0, ylin, /data, color=3, thick=1.5

				prof1 = interpolate(map.data, pixx, pixy, CUBIC=-0.5)
				prof2 = interpolate(map.data, pixx + 3.0/map.dx, pixy, CUBIC=-0.5)
				prof3 = interpolate(map.data, pixx + 6.0/map.dx, pixy, CUBIC=-0.5)
				prof4 = interpolate(map.data, pixx + 9.0/map.dx, pixy, CUBIC=-0.5)
				prof = mean( [ [prof1], [prof2], [prof3], [prof4] ], dim=2)

				distt[i-start, *] = prof 
			
				;loadct, 72, /silent
				wset, 1
				spectro_plot, distt > (-25) < 800, tarr, lindMm, $
								/xs, $
								/ys, $
								ytitle='Distance (Mm)'



				;print, anytim(tarr[i-start], /yoh), ' and '+he_aia.date_obs
				progress_percent, i, start, finish-1
				

			ENDFOR
			
			dt_map_struct = {name:'dt_map_'+WAVEL, dtmap:distt, time:tarr, distance:lindMm, angle:angle, xyarcsec:[[xlin], [ylin]] }
		  	save, dt_map_struct, $
		  		filename='~/Data/2014_apr_18/pulsations/aia_'+WAVEL+'_dt_pulse_traj.sav'

	  	ENDFOR		
  	endfor
	STOP

END