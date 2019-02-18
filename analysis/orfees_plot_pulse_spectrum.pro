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
  				ytitle='Frequency (MHz)', $
  				;title = 'Orfees and DAM', $
  				yr=[ frange[0], frange[1] ], $
  				xrange = [ trange[0], trange[1] ], $
  				/noerase, $
  				;position = [0.42, 0.5, 0.88, 0.92], $
  				xticklen = -0.001, $
  				yticklen = -0.005, $
  				;xtickformat='(A1)', $
  				xtitle = ' '
		
  	
END


pro orfees_plot_pulse_spectrum

	!p.charsize=1.5

	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	time_peak = anytim('2014-04-18T12:56:32', /utim)
	time_trough = anytim('2014-04-18T12:56:33.5', /utim)
	freq0 = 170
	freq1 = 350
	time0 = '20140418_125530'
	time1 = '20140418_125550'
	trange = anytim(file2time([time0, time1]), /utim)
	date_string = time2file(file2time(time0), /date)


	;restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
	restore, orfees_folder+'orf_'+date_string+'_raw_sfu.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = orfees_struct.freq

	;restore, orfees_folder+'orf_'+date_string+'_raw.sav'
	;orf_spec= orfees_struct.spec
	;orf_spec = orf_spec/max(orf_spec)


	orf_spec = constbacksub(orf_spec, /auto)
	;***********************************;
	;			   PLOT
	;***********************************;	
	window, 0, xs=1000, ys=500
	loadct, 74, /silent
	reverse_ct
	plot_spec, orf_spec, orf_time, reverse(orf_freqs), [freq0, freq1], trange, scl0=-1000, scl1=1000.
	
	plots, [time_peak, time_peak], [freq1, freq0], thick=0.8, color=5, /data	
	plots, [time_trough, time_trough], [freq1, freq0], thick=0.8, color=5, /data	
	


	;orf_spec = orf_spec^10.
	;***********************************;
	;	 Plot peak intensity spectrum
	loadct, 0
	window, 1, xs=600, ys=600
	orf_freqs = reverse(orf_freqs)
	ind_f0 = closest(orf_freqs, freq0)
	ind_f1 = closest(orf_freqs, freq1)
	ind_t0 = closest(orf_time, time_peak)
	peak_spectrum = smooth(orf_spec[ind_t0, ind_f1:ind_f0], 2, /edge_mirror)
	loadct, 0

	plot, orf_freqs[ind_f1:ind_f0], peak_spectrum,  $
		;xr=[freq1, freq0], $
		yr=[100, 1000], $
		xr=[freq0, freq1], $
		/xs, $
		/ys, $ 
		;ytickformat='(A1)', $
		ytitle='Flux density (SFU) ', $
		xtitle='Freq (MHz)', $
		position = pos, $
		/noerase, $
		/ylog;, $
		;/xlog

	;*************************************;
	;	 Plot trough intensity spectrum
	ind_t0 = closest(orf_time, time_trough)
	trough_spectrum = smooth(orf_spec[ind_t0, ind_f1:ind_f0], 2, /edge_mirror)	
	oplot, orf_freqs[ind_f1:ind_f0], trough_spectrum, linestyle=3


	;*************************************;
	;	 Plot diff intensity spectrum
	;window, 2, xs=600, ys=600
	diff_spec = trough_spectrum - peak_spectrum
	oplot, orf_freqs[ind_f1:ind_f0], diff_spec, linestyle=3




stop
	;***********************************;
	;	 Plot average intensity spectrum
	loadct, 0
	window, 1, xs=600, ys=600
	time0 = anytim('2014-04-18T12:55:00', /utim)
	time1 = anytim('2014-04-18T12:57:30', /utim)
	ind_t0 = closest(orf_time, time0)
	ind_t1 = closest(orf_time, time1)

	orf_spec_section = orf_spec[ind_t0:ind_t1, ind_f1:ind_f0]

	;stop
	mean_spectrum = smooth(mean(orf_spec_section, dim=1), 2, /edge_mirror)
	loadct, 0

	plot, orf_freqs[ind_f1:ind_f0], mean_spectrum,  $
		;xr=[freq1, freq0], $
		yr=[100, 1000], $
		xr=[freq0, freq1], $
		/xs, $
		/ys, $ 
		;ytickformat='(A1)', $
		ytitle='Flux density (SFU) ', $
		xtitle='Freq (MHz)', $
		position = pos, $
		/noerase, $
		/ylog;, $
		;/xlog

	;set_line_color
	;oplot, [228, 228], [100, 1000], color=3
	;oplot, [228, 228], [100, 1000], color=3
	;oplot, [228, 228], [100, 1000], color=3















END
