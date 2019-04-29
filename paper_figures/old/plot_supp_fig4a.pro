pro setup_ps, name, xsize, ysize

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.2
    device, filename = name, $
        ;/decomposed, $
        /color, $
        /helvetica, $
        /inches, $
        xsize=xsize/100, $
        ysize=xsize/100, $
        /encapsulate, $
        bits_per_pixel=32, $
        yoffset=5

end

pro oplot_hmi_map_20140418

	
	restore, '~/Data/2014_apr_18/pulsations/hmi/hmi_map_20140418.sav'
	hmi_map = map

	hmi_data = hmi_map.data
	hmi_data = bytscl(hmi_map.data, -1e2, 0.7e2)

   	;hmi_data = alog10(hmi_data)/max(alog10(hmi_data))
    hmi_data = smooth(hmi_data, 15)

    hmi_data[0:1600, *]=-1e7
	hmi_data[*, 0:1400]=-1e7
    hmi_map.data = hmi_data

    ;loadct, 0
    ;window, 0, xs=1000, ys=1000
    ;plot_map, hmi_map, $
   	;	CENTER = [0, -250], $ 
	;   FOV = [10, 10]


    levels = [200]

	
	set_line_color
	plot_map, hmi_map, $
		/overlay, $
        /cont, $
        levels=levels, $
        /noxticks, $
        /noyticks, $
        /noaxes, $
        thick=6, $  ; usually 12, 7
        color=0, $
        linestyle=3            

    plot_map, hmi_map, $
		/overlay, $
        /cont, $
        levels=levels, $
        /noxticks, $
        /noyticks, $
        /noaxes, $
        thick=5, $
        color=10, $
        linestyle=3                  

    levels = [40]

    plot_map, hmi_map, $
		/overlay, $
        /cont, $
        levels=levels, $
        /noxticks, $
        /noyticks, $
        /noaxes, $
        thick=5, $
        color=0, $
        linestyle=3             

    plot_map, hmi_map, $
		/overlay, $
        /cont, $
        levels=levels, $
        /noxticks, $
        /noyticks, $
        /noaxes, $
        thick=5, $
        color=4, $
        linestyle=3     
             

END

 pro oplot_radio_src_points, freq, color

    restore, '~/Data/2014_apr_18/pulsations/nrh_'+freq+'_pulse_src1_props_hires_si.sav', /verb  
    t0_points = anytim('2014-04-18T12:55:20', /utim)
    times = anytim(xy_arcs_struct.times, /utim)
    xarcs = xy_arcs_struct.x_max_fit
    yarcs = xy_arcs_struct.y_max_fit
    plotsym, 0, /fill
    colors = findgen(n_elements(xarcs))*(255)/(n_elements(xarcs)-1)
    for i=0, n_elements(xarcs)-1 do begin
      if times[i] gt t0_points then begin
        set_line_color
        ;plots, xarcs[i], yarcs[i], psym=8, color=0, symsize=1.1, thick=2
        ;plots, xarcs[i], yarcs[i], psym=8, color=1, symsize=1.0, thick=2
        loadct, color, /silent
        plots, xarcs[i], yarcs[i], psym=8, color=colors[i], symsize=0.5, thick=1
      endif  
    endfor  
    ;set_line_color
    xarcs = xarcs[where(times gt t0_points)]
    yarcs = yarcs[where(times gt t0_points)]
    plots, mean(xarcs), mean(yarcs), color=0, psym=8, symsize=2, thick=10
    plots, mean(xarcs), mean(yarcs), color=100, psym=8, symsize=1, thick=5

END

pro plot_supp_fig4a, postscript=postscript

	; Get the loop width in AIA at the radio source position
	;

	loadct, 0
	!p.charsize=1.5
	winsz=1100
	AU = 1.49e11	; meters
	aia_waves = ['094A', '131A', '335A']
	angle = 0.0
	npoints = 4000
	radius = 240	;arcsec
	x1 = -150.0
	y1 = -300.0
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
		if keyword_set(postscript) then begin
			setup_ps, '~/small_loop.eps', winsz, winsz
		endif else begin
			window, 0, xs=winsz, ys=winsz, retain = 2;, xpos=1900, ypos=1000
			;window, 1, xs=500, ys=500;, xpos=1900, ypos=100
		endelse	
		
		mreadfits_header, f, ind
		start = closest(anytim(ind.date_obs, /utim), anytim('2014-04-18T12:50:00', /utim))
		finish = closest(anytim(ind.date_obs, /utim), anytim('2014-04-18T13:00:00', /utim))
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
	  
	  	FOR i = start+5, finish DO BEGIN ;n_elements(f)-2 DO BEGIN

			;-------------------------------------------------;
			;			 		Read data
			; 
		
			aia_prep, f[i-5], -1, hdr_pre, img_pre, /uncomp_delete, /norm	
			aia_prep, f[i], -1, hdr, img, /uncomp_delete, /norm	

			iscaled_img = img ;- img_pre
			iscaled_img = smooth((iscaled_img/max(iscaled_img)), 3)

			index2map, hdr, $
				iscaled_img, $
				map, $
				outsize = 4096

			loadct, 0
			;reverse_ct
			plot_map, map, $
				dmin = 5e-4, $
				dmax = 0.5e-2, $
				fov = FOV,$
				center = CENTER

			 ;--------------------------------------------------;
            ;			Plot radio source positions
            ;
			;oplot_radio_src_points, '408', 61
			oplot_radio_src_points, '327', 57 ; Blue
			oplot_radio_src_points, '298', 53 ; Green
			;oplot_radio_src_points, '270', 57 ; Blue
			oplot_radio_src_points, '228', 56 ; Red
		     

            ;loadct, 34, /silent
			;oplot_pfss_20140418_with_color
			restore,'~/Data/2014_apr_18/pulsations/pfss_line_strength_test.sav', /verb ; Made with oplot_pfss_20140418_with_color.pro

			loadct, 39
			;stretch, 0, 100
			colors = findgen(1000)*(255 -1)/999. +1
			;colors = alog10(colors)*100.
  			bfields = (findgen(1000)*(2.8 + 1.0)/999. - 1.0)
			for i=0, n_elements(xlines_total)-1 do begin

				xlines = XLINES_TOTAL[i]
				ylines = YLINES_TOTAL[i]
				field_strength = field_strength_total[i]	; log values
				cols = interpol(colors, bfields, field_strength) 
				
				for jj=1, n_elements(xlines)-1 do begin 
					plots, [xlines[jj], xlines[jj-1]]>(-250)<50, [ylines[jj], ylines[jj-1] ]>(-400)<(-100), col=cols[jj], thick=4.0
				endfor  
				
            endfor	

      


            cgcolorbar, range = [1, 500], $
            		/ylog, $
					/vertical, $
					/right, $
					color=0, $
					pos = [0.87, 0.15, 0.88, 0.85], $
					title = 'Magnetic Field Strength (G)'
			
            if keyword_set(postscript) then device, /close
            set_plot, 'x'
			stop
		ENDFOR
			
  	endfor
	STOP

END