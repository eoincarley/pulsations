pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=0.8
  !p.thick=4
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=7, $
          ysize=2.7, $
          /encapsulate, $
          bits_per_pixel=64, $
          yoffset=5

end

pro plot_spec, data, time, freqs, frange, trange, scl0=scl0, scl1=scl1
	

	print, 'Processing: '+string(freqs[0], format=string('(I4)')) + $
			' to ' + $
			string(freqs[n_elements(freqs)-1], format=string('(I4)'))+ ' MHz'

	spectro_plot, data > scl0 < scl1, $
  				time, $
  				freqs, $
  				/xs, $
  				/ys, $
  				;/ylog, $
				XTICKFORMAT="(A1)", $
				YTICKFORMAT="(A1)", $
				xticklen=-1e-5, $
				yticklen=-1e-5, $
				xtitle=' ', $
  				ytitle=' ', $
  				;title = 'Orfees and DAM', $
  				yr = [ frange[0], frange[1] ], $
  				xrange = [ trange[0], trange[1] ], $
  				/noerase, $
  				position = [0.1, 0.15, 0.9, 0.9]


  	set_line_color
	cgColorbar, Range=[scl0, scl1], $
       OOB_Low='rose', OOB_High='charcoal', /vertical, /right, title='log!L10!N(Flux [SFU])', $
       position = [0.91, 0.15, 0.92, 0.6 ], charsize=0.9, color=0, OOB_FACTOR=0.0, format='(f3.1)', $
       TICKINTERVAL = 0.2

    loadct, 74
	reverse_ct
  	cgColorbar, Range=[scl0, scl1], $
       OOB_Low='rose', OOB_High='charcoal', title='  ', /vertical, /right, $
       position = [0.91, 0.15, 0.92, 0.6 ], charsize=0.9, color=100, ytickformat='(A1)', OOB_FACTOR=0.0, format='(f3.1)', $
       TICKINTERVAL = 0.2
		
  	
END

pro plot_figure2c, postscript=postscript

	; Window setup
	loadct, 0
	if keyword_set(postscript) then begin
        setup_ps, '~/Data/2014_apr_18/pulsations/figure2c.eps
	endif else begin
		window, 0, xs=900, ys=400, retain=2
		!p.thick=1
	endelse

	;-----------------------------------;
	;			Plot Orfees 
	;
	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 170
	freq1 = 300
	time0 = '2014-04-18T12:54:00'
	time1 = '2014-04-18T12:57:40'
	trange = anytim([time0, time1], /utim)

	utplot, trange, [freq1, freq0], /xs, /ys, /noerase, /nodata, $
				xticklen=-1e-2, $
				yticklen=-1e-2, $
				xtitle='Time (UT)', $
				yr = [freq1, freq0], $
  				ytitle='Frequency (MHz)', $
  				position = [0.1, 0.15, 0.9, 0.9]


	restore, orfees_folder+'orf_20140418_raw_sfu.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = reverse(orfees_struct.freq)

	orf_spec = alog10(orf_spec)

	loadct, 74
	reverse_ct
	plot_spec, orf_spec, orf_time, orf_freqs, [freq0, freq1], trange, scl0=2.2, scl1=3.3




if keyword_set(postscript) then device, /close
set_plot, 'x'

stop
END