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
  				position = [0.08, 0.15, 0.7, 0.92], $
  				xticklen = -1e-5, $
  				yticklen = -1e-5, $
  				xtickformat='(A1)', $
  				ytickformat='(A1)', $
  				xtitle = '  '
		
  	
END


pro orfees_pulse_spectrum

	!p.charsize=1.5

	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 190
	freq1 = 220
	time0 = '20140418_125430'
	time1 = '20140418_125730'
	trange = anytim(file2time([time0, time1]), /utim)
	date_string = time2file(file2time(time0), /date)


	restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = reverse(orfees_struct.freq)

	;restore, filename = 'orf_'+date_string+'_polarised.sav'
	;orf_spec_pol = orfees_struct.spec

	;restore, filename = 'orf_'+date_string+'_raw.sav'
	;orf_spec_raw = orfees_struct.spec

	;***********************************;
	;			   PLOT
	;***********************************;	

	;orf_spec_high = simple_pass_filter(data, orf_time, orf_freqs, /high_pass, /time_axis, smoothing=50)
	;orf_spec = orf_spec + 0.5*orf_spec_high
	loadct, 0
	window, 0, xs=1400, ys=600
	utplot, trange, [freq1, freq0], /xs, /ys, $
		yr=[freq1, freq0], $
		position = [0.08, 0.15, 0.7, 0.92], $
  		xtitle = ' Time (UT)', $
  		ytitle = 'Frequency (MHz)', $
  		xticklen = -0.005, $
  		yticklen = -0.01


	loadct, 74, /silent
	reverse_ct
	plot_spec, orf_spec, orf_time, orf_freqs, reverse([freq0, freq1]), trange, scl0=-0.15, scl1=1.3

	ind_f0 = closest(orf_freqs, freq0)
	ind_f1 = closest(orf_freqs, freq1)
	orf_freq_new = orf_freqs[ind_f1:ind_f0]
	orf_time_new = orf_time[where(orf_time ge trange[0] and orf_time le trange[1])]

	fmax_arr = fltarr(n_elements(orf_time_new))
	for i=0, n_elements(orf_time_new)-1 do begin

		time_marker = anytim(orf_time_new[i], /utim)
		plots, [time_marker, time_marker], [freq0, freq1], $
			thick=2, color=5, /data

		
		if time_marker gt trange[0] then plots, [time_marker, time_marker], [freq0, freq1], thick=2, color=5, /data
		ind_t0 = closest(orf_time, time_marker)
		spectrum = orf_spec[ind_t0, ind_f1:ind_f0]

		;loadct, 0
		pos = [0.72, 0.15, 0.98, 0.92]
		plot, [0.02, 1.0], [freq1, freq0], /xs, /ys, $
			yr=[freq1, freq0], $
			xtickformat='(A1)', $
			ytickformat='(A1)', $
			/nodata, xticklen=-1e-6, yticklen=-1e-6, $
			position = pos, $
			/noerase

		plot, spectrum, orf_freq_new, $
			yr=[freq1, freq0], $
			/xs, $
			/ys, $ 
			ytickformat='(A1)', $
			ytitle=' ', $
			xtitle='Intensity (Arbitrary Units)', $
			position = pos, $
			/noerase

		fmax = orf_freq_new[where(spectrum eq max(spectrum)) ]


		if fmax gt 215. or fmax	lt 200 then $
			fmax_arr[i] = fmax_arr[(i-1)>0] $
			else fmax_arr[i] = fmax
	endfor		

	;loadct, 0
	;window, 10
	;utplot, orf_time_new, smooth(fmax_arr, 2), /xs, /ys, yr=[200, 215]

stop
		

	;if time_marker gt trange[0] then plots, [time_marker, time_marker], [0.3, 1.2], thick=1.5, color=10, /data	

END
