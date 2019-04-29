pro setup_ps, name, xsize, ysize

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.5
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

pro plot_figure5a, postscript=postscript

	; Get the loop width in AIA at the radio source position

	; v2 attempting to overplot the NLFFF.

	loadct, 0
	!p.charsize=1.5
	winsz=900
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
			setup_ps, '~/Desktop/field_line_colors.eps', winsz, winsz
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
	  
	  	FOR i = start, finish DO BEGIN ;n_elements(f)-2 DO BEGIN

			;-------------------------------------------------;
			;			 		Read data
			; 
		
			;aia_prep, f[i-5], -1, hdr_pre, img_pre, /uncomp_delete, /norm	
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
				dmax = 1.0e-2, $
				fov = FOV, $
				center = CENTER, $
				title=' ', $
				xtitle = 'X (Mm)', $
				ytitl = 'Y (Mm)', $
				/xs, $
				xticks=4, $
				yticks=4, $
				xtickv = [-250.0, -181.2, -112.4, -43.59, 25.0], $			
				xtickname= ['0','50','100','150','200'], $
				ytickv = -400.0 +indgen(5)*68.8, $
				ytickname= ['0','50','100','150','200']
				;xtickname=strcompress(string(interpol([0, 300], 7)+250, format='(I3)'), /remove_all), $
				;ytickname=strcompress(string(interpol([0, 50], 7)+250, format='(I3)'), /remove_all)
	

			;--------------------------------------------------;
			;			Plot radio source positions
            ;
			;oplot_radio_src_points, '408', 61
			oplot_radio_src_points, '327', 57 ; Blue
			oplot_radio_src_points, '298', 53 ; Green
			;oplot_radio_src_points, '270', 57 ; Blue
			oplot_radio_src_points, '228', 56 ; Red


		    restore, '~/data/2014_apr_18/pulsations/nlfff_lines_bxbybz.sav'
		    ; Note these are in arcsecomd units, built in an 8.25 arcmin FOV at [0, -200]. 
		    ; Have to get the x0 and y0 pix of window in arcseconds,
		    x0 = (0.0 - 8.25*60./2.0)
		    y0 = (-200.0 - 8.25*60.0/2.0)

		    xrange =[-250, 50]
		    yrange =[-400, -100]

		    loadct, 33
		    ncols = 1000.
		    maxb = alog10(560)
		    minb = alog10(2.4)
			bfields = interpol([minb,maxb], ncols)
			colors = interpol([0,255], ncols)

		    for i = 0, n_elements(xlines)-1 do begin
		    	
		    	xline = x0 + xlines[i] ; arcsec
		    	yline = y0 + ylines[i]
		    	indices = where(xline gt xrange[0] and $
		    					xline lt xrange[1] and $
		    					yline gt yrange[0] and $
		    					yline lt yrange[1])

		    	xline = (xline)[indices]
				yline = (yline)[indices]
				bxline = (bx[i])[indices]
				byline = (by[i])[indices]
				bzline = (bz[i])[indices]
	
				field_strength = sqrt(bxline^2 + byline^2 + bzline^2)    
				field_strength = alog10(field_strength)	; log values
				cols = interpol(colors, bfields, field_strength) 

				print, field_strength
		    	;print, n_elements(xlin)
		        ;plots, xlin, ylin, color=1, thick=3
		        ;plots, xlin, ylin, color=10, thick=2

		        for jj=1, n_elements(xline)-1 do begin 
					plots, [xline[jj], xline[jj-1]], [yline[jj], yline[jj-1]], col=cols[jj], thick=5.5
				endfor  



		    endfor    

		   	set_line_color
			cgcolorbar, range = 10^[minb, maxb], $
			        		/xlog, $
							/right, $
							color=0, $
							/top, $
							charsize = 1.55, $
							pos = [0.15, 0.86, 0.85, 0.875], $
							title = ' '

			xyouts, 0.5, 0.92, 'Magnetic Field Strength (G)', /normal, color=0, alignment=0.5

			loadct, 33
            cgcolorbar, range = 10^[minb, maxb], $
            		/xlog, $
					/right, $
					color=1, $
					/top, $
					charsize = 1.55, $
					xtickname=replicate(' ', 5), $
					pos = [0.15, 0.86, 0.85, 0.875], $
					title = ' '

			set_line_color
			; Draw box to idnicate zoom of loop.
			plots, [-130, -34], [-275, -275], linestyle=0, /data, color=1, thick=4
			plots, [-130, -34], [-179, -179], linestyle=0, /data, color=1, thick=4
			plots, [-130, -130], [-275, -179], linestyle=0, /data, color=1, thick=4
			plots, [-34, -34], [-275, -179], linestyle=0, /data, color=1, thick=4	

			
            if keyword_set(postscript) then device, /close
            set_plot, 'x'
			stop
		ENDFOR
			
  	endfor
	STOP

END