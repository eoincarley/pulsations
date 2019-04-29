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
  				position = [0.42, 0.5, 0.88, 0.92], $
  				xticklen = -0.001, $
  				yticklen = -0.005, $
  				xtickformat='(A1)', $
  				xtitle = ' '
		
  	
END


pro orfees_plot_pulsations, freq, time_marker, trange, orf_spec, orf_time, orf_freqs

	; Part of plot_supp_movie1.pro and plot_supp_movie2.pro

	!p.charsize=1.3

	freq0 = 170
	freq1 = 330
	;time0 = '20140418_125630'
	;time1 = '20140418_125700'
	;trange = anytim(file2time([time0, time1]), /utim)
	date_string =  '20140418'	;time2file(trange[0], /date)

	;restore, filename = 'orf_'+date_string+'_polarised.sav'
	;orf_spec_pol = orfees_struct.spec

	;restore, filename = 'orf_'+date_string+'_raw.sav'
	;orf_spec_raw = orfees_struct.spec

	;***********************************;
	;			   PLOT
	;***********************************;	

	loadct, 74, /silent
	reverse_ct

	;orf_spec_high = simple_pass_filter(data, orf_time, orf_freqs, /high_pass, /time_axis, smoothing=50)
	;orf_spec = orf_spec + 0.5*orf_spec_high
	plot_spec, orf_spec, orf_time, orf_freqs, [freq0, freq1], trange, scl0=0.6, scl1=1.15

	
	fcolors = indgen(n_elements(freq))+3

	set_line_color
	for i=0, n_elements(freq)-1 do plots, trange, [freq[i], freq[i]], thick=7.0, color=fcolors[i], /data	
	if time_marker gt trange[0] then plots, [time_marker, time_marker], [freq1, freq0], thick=3.0, color=5, /data	
	
	int_range = [0.1, 0.6]
	for i=0, n_elements(freq)-1 do begin

		index = closest(orf_freqs, freq[i])
		lcurve = orf_spec[*, index]

		if i eq 0 then begin		
		;***********************************;
		;		 Plot Light Curve
		utplot, orf_time, lcurve/max(lcurve), $
			/xs, $
			/ys, $
			linestyle = 0, $
			color = fcolors[i], $
			thick=3, $
			xticklen = 1.0, xgridstyle = 1.0, yticklen = 1.0, ygridstyle = 1.0, $
			ytitle = 'Intensity (arbitrary)', $
			xtitle = 'Time (UT)', $
			position = [0.42, 0.1, 0.88, 0.49], $
			xr = trange, $
			yr=int_range , $
			/normal, $
			/noerase 

			lmax = max(lcurve)
		endif else begin
			if max(lcurve) gt lmax then lmax = max(lcurve)
			outplot, orf_time, lcurve/lmax, color=fcolors[i], thick=3
		endelse	

		if time_marker gt trange[0] then plots, [time_marker, time_marker], [int_range], thick=3.0, color=5, /data	

	endfor


	;***********************************;
	;		Plot Intensity Spectrum

	
	ind_f0 = closest(orf_freqs, freq0)
	ind_f1 = closest(orf_freqs, freq1)
	ind_t0 = closest(orf_time, time_marker)
	spectrum = orf_spec[ind_t0, ind_f1:ind_f0]
	loadct, 0
	pos = [0.885, 0.5, 0.98, 0.92]
	plot, [0.4, 1.2], [freq1, freq0], /xs, /ys, $
		yr=[freq1, freq0], $
		xtickformat='(A1)', $
		ytickformat='(A1)', $
		/nodata, xticklen=-1e-6, yticklen=-1e-6, $
		position = pos, $
		/noerase

	plot, spectrum, orf_freqs[ind_f1:ind_f0], $
		yr=[freq1, freq0], $
		xr=[0.1, 1.0], $
		/xs, $
		/ys, $ 
		ytickformat='(A1)', $
		ytitle=' ', $
		xtitle='Intensity (Arb. unit)', $
		position = pos, $
		/noerase

END
