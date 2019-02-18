pro stamp_date, wave1, wave2, wave3
   set_line_color

   xpos_aia_lab = 0.17
   ypos_aia_lab = 0.83

   lbl_shift=0.003
   xyouts, xpos_aia_lab+lbl_shift, ypos_aia_lab+0.07, wave1, alignment=0, /normal, color = 1, charthick=5
   xyouts, xpos_aia_lab-lbl_shift, ypos_aia_lab+0.07, wave1, alignment=0, /normal, color = 1, charthick=5
   xyouts, xpos_aia_lab, ypos_aia_lab+0.07, wave1, alignment=0, /normal, color = 3, charthick=0.5
   
   xyouts, xpos_aia_lab+lbl_shift, ypos_aia_lab+0.035, wave2, alignment=0, /normal, color = 0, charthick=5
   xyouts, xpos_aia_lab-lbl_shift, ypos_aia_lab+0.035, wave2, alignment=0, /normal, color = 0, charthick=5
   xyouts, xpos_aia_lab, ypos_aia_lab+0.035, wave2, alignment=0, /normal, color = 4, charthick=2
   
   xyouts, xpos_aia_lab+lbl_shift, ypos_aia_lab, wave3, alignment=0, /normal, color = 0, charthick=5
   xyouts, xpos_aia_lab-lbl_shift, ypos_aia_lab, wave3, alignment=0, /normal, color = 0, charthick=5
   xyouts, xpos_aia_lab, ypos_aia_lab, wave3, alignment=0, /normal, color = 10, charthick=2

END

pro aia_dt_plot_pulsations_v2, postscript=postscript, choose_points=choose_points, ratio=ratio

	; Code to plot the distance time maps from AIA

	; v2 Get dt trace along radio pulsation source trajectory.

	!p.font = 0
	!p.charsize = 1.0
	loadct, 0
	;!p.charthick = 0.5

	folder = '~/Data/2014_apr_18/pulsations/'	;'~/Data/2014_Apr_18/sdo/'	;'~/Data/2015_nov_04/sdo/event1/'
	
	if keyword_set(postscript) then begin
		set_plot, 'ps'
		device, filename='~/aia_dt_maps_gcircles_20140418.eps', $
				/encapsulate, $
				/color, $ 
				/inches, $
				/helvetica, $
				bits_per_pixel=32, $
				xs=5, $
				ys=5
	endif else begin
		window, 0, xs=800, ys=800
	endelse

	min_scl = -2
	max_scl = 2
	;-------------------------------------------;
	;				Plot 171
	;
	;angle = '020'
	waves = ['094', '131', '335']	;['211', '193', '171']		;['094', '131', '335']	;
	cd, folder
	restore,'aia_'+waves[0]+'_dt_pulse_traj.sav' 
	t_a = dt_map_struct.time
	lindMm = dt_map_struct.distance	
	distt_a = dt_map_struct.dtmap
	if ~keyword_set(ratio) then begin
		for i=0, n_elements(lindMm)-1 do distt_a[*,i] = ( distt_a[*,i] - mean(distt_a[*,i]) ) /stdev(distt_a[*,i] )   
		distt_a = distt_a > (min_scl) < (max_scl)
	endif else begin
		distt_a = distt_a/max(distt_a)
	endelse	

	restore,'aia_'+waves[1]+'_dt_pulse_traj.sav' 
	t_b = dt_map_struct.time
	distt_b = dt_map_struct.dtmap
	if ~keyword_set(ratio) then begin
		for i=0, n_elements(lindMm)-1 do distt_b[*,i] = ( distt_b[*,i] - mean(distt_b[*,i]) ) /stdev(distt_b[*,i] )   
		distt_b = distt_b > (min_scl) < (max_scl)
	endif else begin
		distt_b = distt_b/max(distt_b)
	endelse	

	restore,'aia_'+waves[2]+'_dt_pulse_traj.sav' 
	t_c = dt_map_struct.time
	distt_c = dt_map_struct.dtmap
	if ~keyword_set(ratio) then begin
		for i=0, n_elements(lindMm)-1 do distt_c[*,i] = ( distt_c[*,i] - mean(distt_c[*,i]) ) /stdev(distt_c[*,i] )   
		distt_c = distt_c > (min_scl) < (max_scl)
	endif else begin
		distt_c = distt_c/max(distt_c)
	endelse	

	arrs = [n_elements(t_a), n_elements(t_b), n_elements(t_c)]
	val = max(arrs, t_max, subscript_min = t_min)
	n_array = [0,1,2]


	case t_min of
	  0: image_time = t_a
	  1: image_time = t_b
	  2: image_time = t_c
	endcase

	t_mid = n_array[where(n_array ne t_max and n_array ne t_min)]

	if t_min eq t_max then begin
	     max_tim = t_a
	     mid_tim = t_b
	     min_tim = t_c
	endif else begin
	  case t_max of
	     0: max_tim = t_a
	     1: max_tim = t_b
	     2: max_tim = t_c
	  endcase
	  case t_min of
	     0: min_tim = t_a
	     1: min_tim = t_b
	     2: min_tim = t_c
	  endcase
	  case t_mid of
	     0: mid_tim = t_a
	     1: mid_tim = t_b
	     2: mid_tim = t_c
	  endcase
	endelse


	; This loop finds the closest file to min_tim[n] for each of the filters. It constructs an
	; array of indices for each of the filters.
	for n = 0, n_elements(min_tim)-1 do begin
	  sec_min = min(abs(min_tim - min_tim[n]), loc_min)
	  if n eq 0 then next_min_im = loc_min else next_min_im = [next_min_im, loc_min]

	  sec_max = min(abs(max_tim - min_tim[n]), loc_max)
	  if n eq 0 then next_max_im = loc_max else next_max_im = [next_max_im, loc_max]

	  sec_mid = min(abs(mid_tim - min_tim[n]), loc_mid)
	  if n eq 0 then next_mid_im = loc_mid else next_mid_im = [next_mid_im, loc_mid]
	endfor

	if t_min eq t_max then begin
	     loc_a = next_max_im
	     loc_b = next_mid_im
	     loc_c = next_min_im
	endif else begin
	  case t_max of
	     0: loc_a = next_max_im
	     1: loc_b = next_max_im
	     2: loc_c = next_max_im
	  endcase
	  case t_mid of
	     0: loc_a = next_mid_im
	     1: loc_b = next_mid_im
	     2: loc_c = next_mid_im
	  endcase
	  case t_min of
	     0: loc_a = next_min_im
	     1: loc_b = next_min_im
	     2: loc_c = next_min_im
	  endcase
	endelse  

	distt_a = distt_a[loc_a, *] 
	distt_b = distt_b[loc_b, *] 
	distt_c = distt_c[loc_c, *] 
	
	step_size = 10			;********** STEP SIZE FOR RATIO ***********;
	sizex = (size(distt_a))[1]
	sizey = (size(distt_a))[2]
	plota = fltarr(sizex, sizey)
	plotb = fltarr(sizex, sizey)
	plotc = fltarr(sizex, sizey)
	;min_tim = min_tim[step_size:n_elements(min_tim)-1]
	
	distt_a_hf = distt_a - smooth(distt_a, 30)
	distt_b_hf = distt_b - smooth(distt_b, 30)
	distt_c_hf = distt_c - smooth(distt_c, 30)

	distt_a_lf = smooth(distt_a, 2)
	distt_b_lf = smooth(distt_b, 2)
	distt_c_lf = smooth(distt_c, 2)

	;distt_a = (distt_a) - 1.7*distt_a_hf
	;distt_b = (distt_b) - 1.7*distt_b_hf
	;distt_c = (distt_c) - 1.7*distt_c_hf

	;distt_a = (smooth(distt_a, 2)) ; - distt_a_hf
	;distt_b = (smooth(distt_b, 2)) ; - distt_b_hf
	;distt_c = (smooth(distt_c, 2)) ; - distt_c_hf

	;for i=0, n_elements(distt_a[*, 0])-1 do distt_a[i, *] = smooth(distt_a[i, *], 10, /edge_mirror)
	;for i=0, n_elements(distt_b[*, 0])-1 do distt_b[i, *] = smooth(distt_b[i, *], 10, /edge_mirror)
	;for i=0, n_elements(distt_c[*, 0])-1 do distt_c[i, *] = smooth(distt_c[i, *], 10, /edge_mirror)

	
	min_scl =  0.97
	max_scl =  1.11
	if ~keyword_set(ratio) then begin
			plota = (distt_a)	;/distt_a[i-5, *] >0.8 <1.15 
			plotb = (distt_b)	;/distt_b[i-5, *] >0.8 <1.15
			plotc = (distt_c)	;/distt_c[i-5, *] >0.8 <1.15
	endif else begin
		for i=step_size, sizex-1 do begin
			plota[i, *] =  distt_a[i, *] - distt_a[(i-step_size)>0, *]  ;>min_scl < max_scl ) ;^4	
			plotb[i, *] =  distt_b[i, *] - distt_b[(i-step_size)>0, *]  ;>min_scl < max_scl ) ;^4
			plotc[i, *] =  distt_c[i, *] - distt_c[(i-step_size)>0, *]  ;>min_scl < max_scl ) ;^4
		endfor
	endelse
	;plota = filter_image(plota, fwhm=3)
	;plotb = filter_image(plotb, fwhm=3)
	;plotc = filter_image(plotc, fwhm=3)
	
	for i=0, n_elements(plota[*, 0])-1 do plota[i, *] = smooth(plota[i, *], 3)
	for i=0, n_elements(plotb[*, 0])-1 do plotb[i, *] = smooth(plotb[i, *], 3)
	for i=0, n_elements(plotc[*, 0])-1 do plotc[i, *] = smooth(plotc[i, *], 3)



	tstart = anytim('2014-04-18T12:45:00', /utim) > min_tim[0] ;anytim('2014-04-18T12:00:00',/utim) > min_tim[0]
	tend = anytim('2014-04-18T13:25:00', /utim) < min_tim[n_elements(min_tim)-1] ;anytim('2014-04-18T13:10:00', /utim)	< min_tim[n_elements(min_tim)-1]
	istart = closest(min_tim, tstart)
	istop = closest(min_tim, tend)
	
	;-------------------------------------------;
	;	The deletion of AIA images with an incorrect exposure time leads to the images having an uneven sampling in time.
	;	The following two for loops find where the time is unevenly sampled and inserts new times at the mininum sampling
	;   of AIA (12 seconds). This gives an evenly sampled time array between start and end times with a cadence of 12 s.
	;
	min_t_int = 1.0
	new_min_tim = min_tim[0]
	for i=1, n_elements(min_tim)-1 do begin

		int = min_tim[i] - min_tim[i-1] 
		if int gt min_t_int then begin
			n_new_tims = (int - (int mod min_t_int))/min_t_int
			new_tims = (dindgen(n_new_tims)+1)*min_t_int + min_tim[i-1] 
			new_min_tim = [new_min_tim, new_tims]	
		endif else begin
			new_min_tim = [new_min_tim, min_tim[i]]
		endelse

	endfor
	;-------------------------------------------;
	;		Now create evenly space dt map
	;
	new_map_a = findgen(n_elements(new_min_tim), n_elements(lindMm))
	new_map_b = findgen(n_elements(new_min_tim), n_elements(lindMm))
	new_map_c = findgen(n_elements(new_min_tim), n_elements(lindMm))

	for i=0, n_elements(new_min_tim)-1 do begin
		index = closest(min_tim, new_min_tim[i])
		new_map_a[i, *] = plota[index, *]
		new_map_b[i, *] = plotb[index, *]
		new_map_c[i, *] = plotc[index, *]
	endfor
	
	; Take section of the array
	hstart = 10.0 	;Mm
	hstop = 200.0 	;Mm
	hindex0 = closest(lindMm, hstart)
	hindex1 = closest(lindMm, hstop)
	istart = closest(new_min_tim, tstart)
	istop = closest(new_min_tim, tend)

	truecolorim = [[[ new_map_a[istart:istop, hindex0:hindex1] ]], [[ new_map_b[istart:istop, hindex0:hindex1] ]], [[ new_map_c[istart:istop, hindex0:hindex1] ]]]
	
	;window, 0, xs=500, ys=500	 

	;-------------------------------------------;
	;		PLOT three colour map
	;
	;truecolorim[*, *, 1]=truecolorim[*, *, 2]*0.5 + truecolorim[*, *, 0]*0.5
	plot_image, truecolorim[*, *, *], true=3, $	;usually img
    	position = [0.15, 0.15, 0.95, 0.95], $
    	XTICKFORMAT="(A1)", $
    	YTICKFORMAT="(A1)", $
	 	/noerase, $
	 	/normal, $
	 	xticklen=-0.001, $
        yticklen=-0.001       

    ; This allows a point and click for the distance and time.    
 	utplot, new_min_tim, lindMm, $	;/rsun + 0.9, $
	 	/nodata, $
	 	/xs, $
	 	/ys, $
	 	yr=[lindMm(hindex0), lindMm(hindex1)], $	;/rsun + 0.9, $
	  	xr = [tstart, tend], $
		position = [0.15, 0.15, 0.95, 0.95], $
		/noerase, $
		/normal, $
    	ytitle='Distance (Mm)'


    stamp_date, 'AIA '+waves[0]+' '+cgsymbol('angstrom'), 'AIA '+waves[1]+' '+cgsymbol('angstrom'), 'AIA '+waves[2]+' '+cgsymbol('angstrom')
    if waves[0] eq '094' then channels = 'hot' else channels='cool'
			
	if keyword_set(choose_points) then begin
		point, tim, dis, /data
		print, tim
		;map_points = { name:'dt_map_points', times:tim, dis:dis, angle:angle, waves:waves }
		;save, map_points, filenam='aia_'+channels+'_dtpoints_'+angle+'.sav'


		;---------------------------------------;
		;			  Calc speed
		;
		window, 1, xs=600, ys=600
			loadct, 0		

		utplot, tim, dis, $
			ytitle='Displacement (km)', $
			linestyle=0, $
			xr=[tim[0], tim[n_elements(tim)-1]], $
			;yr=[0, 400], $
			/xs, $
			/ys, $
			/noerase

		tims_sec = anytim(tim, /utim) - anytim(tim[0], /utim)		
		result = linfit(tims_sec, dis, yfit=yfit)

		err = dis
		err[*] = 10. 
		start = [400, 1000.0]
		fit = 'p[1]*x + p[0]'			
		
		p = mpfitexpr(fit, tims_sec, dis, err, perror=perror, yfit=yfit, start);, parinfo=q)
		outplot, tim, yfit, linestyle=1

		tsim = (findgen(100)*( tims_sec[n_elements(tims_sec)-1] - tims_sec[0])/99.0 )+tims_sec[0]
		ysim = p[1]*tsim + p[0]

		print, 'Initial speed: '+string( p[1]*1e3 ) +' '+ string(perror[1])
	endif

	tim_marker = anytim('2014-04-18T12:55', /utim)
	set_line_color
	plots, [tim_marker, tim_marker], [0, 400], linestyle=2, color=1, thick=5
	plots, [anytim('2014-04-18T12:32', /utim), anytim('2014-04-18T13:15', /utim)], [150, 150], linestyle=2, color=3, thick=5
	plots, [anytim('2014-04-18T12:32', /utim), anytim('2014-04-18T13:15', /utim)], [200, 200], linestyle=2, color=3, thick=5
	
	if keyword_set(postscript) then begin
		device, /close
		set_plot,'x'
	endif
		
stop

END