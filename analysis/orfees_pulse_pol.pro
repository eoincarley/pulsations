pro plot_spec, data, time, freqs, frange, trange, scl0=scl0, scl1=scl1
	

	print, 'Processing: '+string(freqs[0], format=string('(I4)')) + $
			' to ' + $
			string(freqs[n_elements(freqs)-1], format=string('(I4)'))+ ' MHz'

	

	;kernelSize = [2, 2]
	;kernel = REPLICATE(-1., kernelSize[0], kernelSize[1])
	;kernel[1, 1] = 8
	 
	; Apply the filter to the image.
	; data = CONVOL(data, kernel, $
	;  /CENTER, /EDGE_TRUNCATE)


	spectro_plot, data > (scl0) < (scl1), $
  				time, $
  				freqs, $
  				/xs, $
  				/ys, $
  				;/ylog, $
  				ytitle='Frequency (MHz)', $
  				;title = 'Orfees and DAM', $
  				yr=[ frange[0], frange[1] ], $
  				xrange = [ trange[0], trange[1] ], $
  				;/noerase, $
  				;position = [0.5, 0.15, 0.95, 0.95], $
  				xticklen = -0.012, $
  				yticklen = -0.015, $
  				;xtickformat='(A1)', $
  				xtitle = 'Time (UT)'
		
  	
END


pro orfees_pulse_pol


	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 150
	freq1 = 1000
	time0 = anytim('2014-04-18T12:40:20', /utim)
	time1 = anytim('2014-04-18T12:58:40', /utim)
	date_string = time2file(time0, /date)


	
	restore, filename = orfees_folder+'orf_'+date_string+'_raw.sav'
	orf_spec_raw = orfees_struct.spec
	orf_spec_raw = orf_spec_raw
	orf_time = orfees_struct.time
	orf_freqs = orfees_struct.freq

	tindices = where(orf_time ge time0 and orf_time le time1)
	orf_time = orf_time[tindices]
	orf_spec_raw = orf_spec_raw[tindices, *]
	orf_spec_raw = orf_spec_raw/max(orf_spec_raw)

	restore, filename = orfees_folder+'orf_'+date_string+'_polarised.sav'
	orf_spec_pol = orfees_struct.spec
	orf_time = orfees_struct.time
	tindices = where(orf_time ge time0 and orf_time le time1)
	orf_time = orf_time[tindices]
	orf_spec_pol = orf_spec_pol[tindices, *]
	orf_spec_pol = orf_spec_pol/max(orf_spec_pol)

	;***********************************;
	;			   PLOT
	;***********************************;	

	loadct, 72, /silent


	data = orf_spec_pol/orf_spec_raw 


	plot_spec, data, orf_time, reverse(orf_freqs), [freq0, freq1], [time0, time1], scl0=-0.5, scl1=0.5
	stop


END
