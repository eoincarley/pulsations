pro setup_ps, name
    set_plot,'ps'
    !p.font=0
    !p.charsize=1.2
    device, filename = name, $
        ;/decomposed, $
        /color, $
        /helvetica, $
        /inches, $
        xsize=11, $
        ysize=7, $
        /encapsulate, $
        bits_per_pixel=32, $
        yoffset=5

end        
pro plot_spec, data, time, freqs, frange, trange, scl0=scl0, scl1=scl1
	

	print, 'Processing: '+string(freqs[0], format=string('(I4)')) + $
			' to ' + $
			string(freqs[n_elements(freqs)-1], format=string('(I4)'))+ ' MHz'


	;kernelSize = [2, 2]
	;kernel = REPLICATE(-1., kernelSize[0], kernelSize[1])
	;kernel[1, 1] = 8
	 
	; Apply the filter to the image.
	;data = CONVOL(data, kernel, $
	;  /CENTER, /EDGE_TRUNCATE)


	spectro_plot, data > (scl0) < (scl1), $
  				time, $
  				freqs, $
  				/xs, $
  				/ys, $
  				;/ylog, $
  				ytitle=' ', $
  				;title = 'Orfees and DAM', $
  				yr=[ frange[0], frange[1] ], $
  				xrange = [ trange[0], trange[1] ], $
  				/noerase, $
  				position = [0.1, 0.1, 0.9, 0.95], $
  				xticklen = -1e-6, $
  				yticklen = -1e-6, $
  				xtickformat='(A1)', $
  				ytickformat='(A1)', $
  				xtitle = ' '


  	set_line_color
	cgColorbar, Range=[scl0, scl1], $
       OOB_Low='rose', OOB_High='charcoal', /vertical, /right, title='Normalised flux', $
       position = [0.91, 0.1, 0.92, 0.6 ], charsize=1.0, color=0, OOB_FACTOR=0.0, format='(f3.1)', $
       TICKINTERVAL = 0.2

    loadct, 74
	reverse_ct
  	cgColorbar, Range=[scl0, scl1], $
       OOB_Low='rose', OOB_High='charcoal', title='  ', /vertical, /right, $
       position = [0.91, 0.1, 0.92, 0.6 ], charsize=1.0, color=100, ytickformat='(A1)', OOB_FACTOR=0.0, format='(f3.1)', $
       TICKINTERVAL = 0.2
					
		
  	
END


pro plot_supp_fig7, postscript=postscript

	if ~keyword_set(postscript) then begin
		!p.charsize=1.5
		window, xs=1000, ys=600
	endif else begin	
		setup_ps, '~/sudden_reductions.eps'
	endelse

	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 180
	freq1 = 300
	time0 = '20140418_125640'
	time1 = '20140418_125730'
	trange = anytim(file2time([time0, time1]), /utim)
	date_string = time2file(file2time(time0), /date)


	restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
	orf_spec = orfees_struct.spec
	orf_spec = 3.3*orf_spec/max(orf_spec)
	orf_time = orfees_struct.time
	orf_freqs = orfees_struct.freq

	;***********************************;
	;			   PLOT
	;***********************************;	
	loadct, 0
	utplot, trange, [freq1, freq0], /xs, /ys, $
			yr=[freq1, freq0], $
			xtitle = 'Time (UT)', $
			/nodata, $
			ytitle = 'Frequency (MHz)', $
			xticklen = -0.01, $
			yticklen = -0.01, $
			position = [0.1, 0.1, 0.9, 0.9]


	loadct, 74, /silent
	reverse_ct

	plot_spec, (orf_spec), orf_time, reverse(orf_freqs), [freq0, freq1], trange, scl0=0.1, scl1=1.0

	if keyword_set(postscript) then begin
		device, /close
		set_plot, 'x'
	endif
	


END
