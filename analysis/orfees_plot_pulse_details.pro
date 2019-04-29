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
  				;position = [0.42, 0.5, 0.88, 0.92], $
  				xticklen = -1e-6, $
  				yticklen = -1e-6, $
  				xtickformat='(A1)', $
  				ytickformat='(A1)', $
  				xtitle = ' '
		
  	
END


pro orfees_plot_pulse_details

	!p.charsize=1.5
	window, 0, xs=1000, ys=600

	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	freq0 = 170
	freq1 = 300
	time0 = '20140418_125400'
	time1 = '20140418_125740'
	trange = anytim(file2time([time0, time1]), /utim)
	date_string = time2file(file2time(time0), /date)


	restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
	orf_spec = orfees_struct.spec
	orf_time = orfees_struct.time
	orf_freqs = orfees_struct.freq

	;restore, orfees_folder+'orf_'+date_string+'_polarised.sav'
	;orf_spec = orfees_struct.spec

	;restore, filename = 'orf_'+date_string+'_raw.sav'
	;orf_spec_raw = orfees_struct.spec

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
			yticklen = -0.01


	loadct, 74, /silent
	reverse_ct

	;orf_spec_high = simple_pass_filter(data, orf_time, orf_freqs, /high_pass, /time_axis, smoothing=50)
	;orf_spec = orf_spec + 0.5*orf_spec_high

	plot_spec, (orf_spec), orf_time, reverse(orf_freqs), [freq0, freq1], trange, scl0=0.0, scl1=1.0

	
	;fcolors = indgen(n_elements(freq))+3
	loadct, 0
	window, 1, xs=1000, ys=600
	set_line_color
	;for i=0, n_elements(freq)-1 do plots, trange, [freq[i], freq[i]], thick=0.8, color=fcolors[i], /data	
	;if time_marker gt trange[0] then plots, [time_marker, time_marker], [freq1, freq0], thick=0.8, color=5, /data	
	
	;for i=0, n_elements(freq)-1 do begin

		freq_array = reverse(orf_freqs)
		index = closest(freq_array, 208.0)
		lcurve = orf_spec[*, index]

	;	if i eq 0 then $
		;***********************************;
		;		 Plot Light Curve
		utplot, orf_time, lcurve/max(lcurve), $
			/xs, $
			/ys, $
			linestyle = 0, $
			color = 4, $
			thick=1, $
			xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
			ytitle = 'Intensity (arbitrary)', $
			xtitle = 'Time (UT)', $
			;position = [0.42, 0.1, 0.88, 0.49], $
			xr = anytim(file2time([time0, time1]), /utim), $
			yr=[0.0, 0.6], $
			/normal, $
			/noerase
	;	else $

		freq_array = reverse(orf_freqs)
		index = closest(freq_array, 900.0)
		lcurve = orf_spec[*, index]
		outplot, orf_time, lcurve/max(lcurve), color=5

	;	if time_marker gt trange[0] then plots, [time_marker, time_marker], [0.0, 0.6], thick=0.8, color=10, /data	

	;endfor


END
