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

pro plot_plane, xrange, yrange, zrange
	
	xplane = interpol([xrange[0], xrange[1]], 100)
	yplane = interpol([yrange[0], yrange[1]], 100)
	zplane = interpol([zrange[0], zrange[1]], 100)

	loadct, 0, /silent
	plots, xplane, $
		   yplane, $
		   zplane, $
		   col=20., $
		   thick=1.0, $
		   /t3d

end

pro plot_nlfff_3D_colors, postscript=postscript

	; Get the loop width in AIA at the radio source position
	; v2 attempting to overplot the NLFFF.



	loadct, 0
	!p.charsize=1.5
	winsz=800
	AU = 1.49e11	; meters
	aia_waves = ['094A', '131A', '335A']
	angle = 0.0
	npoints = 4000
	radius = 240	;arcsec
	x1 = -150.0
	y1 = -300.0
	FOV = [5.0, 5.0]
	CENTER = [-100.0, -250.0]

	;-------------------------------------------------;
	;
	;		  Choose files unaffected by AEC
	;
	folder = '~/Data/2014_Apr_18/sdo/171A/'
	aia_files = findfile(folder+'aia*.fits')
	mreadfits_header, aia_files, ind, only_tags='exptime'
	f = aia_files[where(ind.exptime gt 1.)]

	;window, 0, xs=winsz, ys=winsz, retain = 2, xpos=1900, ypos=1000
	if keyword_set(postscript) then begin
		setup_ps, '~/field_line_colors.eps', winsz, winsz
	endif else begin
		window, 0, xs=winsz, ys=winsz, retain = 2;, xpos=1900, ypos=1000
		;window, 1, xs=500, ys=500;, xpos=1900, ypos=100
	endelse	


	;----------------------------------------------------;
	;
	;		Define lines over which to interpolate
	;
	read_sdo, f[0], hdr, aia_img

    restore, '~/data/2014_apr_18/pulsations/nlfff_lines_bxbybz.sav'
    ; Note these are in pixel units, built in an 8.25 arcmin FOV at [0, -200]. Have to get the x and y 0 pix of window,
    ; then add the line coord pix, then covert to xarcs and yarcs.
    x0 = (0.0 - 8.25*60./2.0)/hdr.cdelt1 + hdr.crpix1
    y0 = (-200.0 - 8.25*60.0/2.0)/hdr.cdelt2 + hdr.crpix2
	

	for angx=90, 0, -1 do begin

		;----------------------------------------------------;
		;--------------Set up 3D environment-----------------;
		;----------------------------------------------------;
		loadct, 0
		wset, 0
		box_sz = 250.  ; Mm
	 	x_range = [80.0, 190.] ;[0.1, 1.5]
	  	y_range = [150, 250.] ;[0.1, 1.2]
	   	z_range = [0.0, 200.]

		surface, dist(5), /nodata, /save, xrange=x_range, yrange=y_range, $
			zrange=z_range, ax=15, az=15.,  $
			xtit=' ', ytitle=' ', ztitle ='Altitude (Mm)', /xs, /ys, /zs, $
			position = [0.15, 0.15, 0.85, 0.85], /normal, $
			ZTICKLEN=1,  ZGRIDSTYLE=1

		plots, [x_range[1], x_range[1]], [y_range[0], y_range[1]], [0.0, 0.0], $
			linestyle=1, /t3d		
		plots, [x_range[1], x_range[1]], [y_range[0], y_range[1]], [50.0, 50.0], $
			linestyle=1, /t3d
		plots, [x_range[1], x_range[1]], [y_range[0], y_range[1]], [100.0, 100.0], $
			linestyle=1, /t3d
		plots, [x_range[1], x_range[1]], [y_range[0], y_range[1]], [150.0, 150.0], $
			linestyle=1, /t3d
		plots, [x_range[1], x_range[1]], [y_range[0], y_range[1]], [200.0, 200.0], $
			linestyle=1, /t3d
		plots, [x_range[1], x_range[1]], [y_range[0], y_range[0]], [z_range[0], z_range[1]], $
			linestyle=0, /t3d	
		plots, [x_range[1], x_range[1]], [y_range[1], y_range[1]], [z_range[0], z_range[1]], $
			linestyle=0, /t3d		
					


	    ncols = 1000.
	    colors = findgen(ncols)*(255)/999.
	    maxb = 3.0
	    minb = 1e-2
		bfields = (findgen(ncols)*(maxb + minb)/(ncols-1) - minb)
	    for i = 0, n_elements(xlines)-10 do begin
	    
	    	bx_lin = reverse(bx[i])	
			by_lin = reverse(by[i])	
			bz_lin = reverse(bz[i])		
			field_strength = sqrt(bx_lin^2 + by_lin^2 + bz_lin^2)    
			field_strength = alog10(field_strength)	; log values
	    	xlin = reverse(xlines[i])    ; Mm
	    	ylin = reverse(ylines[i]) 
	    	zlin = reverse(zlines[i]) 
	    	zeros = zlin
	    	zeros[*] = 0.0
			cols = interpol(colors, bfields, field_strength) 

			for jj=1, n_elements(xlin)-1 do begin 
	        	if xlin[jj] gt x_range[0] and xlin[jj] lt x_range[1] and ylin[jj] gt y_range[0] and ylin[jj] lt y_range[1] then begin
 
	        		loadct, 0.0, /silent
					plots, [xlin[jj], xlin[jj-1]], $
						   [y_range[1], y_range[1]], $
						   [zlin[jj], zlin[jj-1]], $
						   col=100., $
						   thick=1.0, $
						   linestyle=1, $
						   /t3d
				endif		   
			endfor			

	        for jj=1, n_elements(xlin)-1 do begin 
	        	if xlin[jj] gt x_range[0] and xlin[jj] lt x_range[1] and ylin[jj] gt y_range[0] and ylin[jj] lt y_range[1] then begin

					plots, [xlin[jj], xlin[jj-1]], $
						   [ylin[jj], ylin[jj-1]], $
						   [0.0, 0.0], $
						   col=100., $
						   linestyle=1, $
						   thick=1.0, $
						   /t3d
				endif		   
			endfor	

	        for jj=1, n_elements(xlin)-1 do begin 
	        	if xlin[jj] gt x_range[0] and xlin[jj] lt x_range[1] and ylin[jj] gt y_range[0] and ylin[jj] lt y_range[1] then begin

					plots, [x_range[1], x_range[1]], $
						   [ylin[jj], ylin[jj-1]], $
						   [zlin[jj], zlin[jj-1]], $
						   col=100., $
						   linestyle=1, $
						   thick=1.0, $
						   /t3d
				endif		   
			endfor			   

			for jj=1, n_elements(xlin)-1 do begin 
	        	if xlin[jj] gt x_range[0] and xlin[jj] lt x_range[1] and ylin[jj] gt y_range[0] and ylin[jj] lt y_range[1] then begin
 
 					loadct, 27, /silent
					plots, [xlin[jj], xlin[jj-1]], $
						   [ylin[jj], ylin[jj-1]], $
						   [zlin[jj], zlin[jj-1]], $
						   col=cols[jj], $
						   thick=2.0, $
						   /t3d
	   
				endif		   
			endfor  

	    endfor    

	    cgcolorbar, range = 10^[minb, maxb], $
    		/ylog, $
			/right, $
			/vertical, $
			color=1, $
			pos = [0.86, 0.1, 0.87, 0.96], $
			title = 'Magnetic Field Strength (G)'
		stop
	    x2png, '~/Data/2014_apr_18/pulsations/nlfff_3D/image_'+string(ang, format='(I04)')+'.png'
    endfor

		
    if keyword_set(postscript) then device, /close
    set_plot, 'x'
	

STOP
END