pro plot_spec, data, time, freqs, frange, trange, scl0=scl0, scl1=scl1, plt_pos=plt_pos
	

	print, 'Processing: '+string(freqs[0], format=string('(I4)')) + $
			' to ' + $
			string(freqs[n_elements(freqs)-1], format=string('(I4)'))+ ' MHz'

	trange = anytim(file2time(trange), /utim)
	spectro_plot, data > (scl0) < (scl1), $
  				time, $
  				freqs, $
  				/xs, $
  				/ys, $
  				/ylog, $
  				;color=0, $
				;XTICKFORMAT="(A1)", $
				;YTICKFORMAT="(A1)", $
				xtitle=' ', $
  				ytitle='Frequency (MHz)', $
  				title = 'Orfees and Ondrejov RT5', $
  				yr=[ frange[0], frange[1] ], $
  				xrange = [ trange[0], trange[1] ], $
  				/noerase, $
  				position = plt_pos, $
  				xticklen = -0.012, $
  				ytickval = [100,200,1000],  $
  				yticklen = -0.015
		  	
END


pro read_dam, date_string, $
	dam_spec, dam_times, dam_freqs

	restore, 'NDA_'+date_string+'_1051.sav', /verb
	dam_freqs = nda_struct.freq
	daml = nda_struct.spec_left
	damr = nda_struct.spec_right
	times = nda_struct.times

	restore, 'NDA_'+date_string+'_1151.sav', /verb
	daml = [daml, nda_struct.spec_left]
	damr = [damr, nda_struct.spec_right]
	times = [times, nda_struct.times]

	restore, 'NDA_'+date_string+'_1251.sav', /verb
	daml = [daml, nda_struct.spec_left]
	damr = [damr, nda_struct.spec_right]
	times = [times, nda_struct.times]
	
	dam_spec = damr + daml
	dam_times = times

END

pro plot_nda_orfees_ondrejov, time_marker

	window, 0, xs=800, ys=500
	loadct, 3
	!p.background=255
	!p.color=0
	!p.charsize=1.2
	pos0 = [0.12, 0.12, 0.95, 0.95]

	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
	dam_folder = '~/Data/2014_apr_18/radio/dam/'
	freq0 = 100
	freq1 = 2000
	time0 = '20140418_125520'
	time1 = '20140418_125620'
	trange = anytim(file2time([time0, time1]), /utim)
	date_string = time2file(file2time(time0), /date)


	;***********************************;
	;		   Read NDA (DAM)		
	;***********************************;
		
	cd, dam_folder
	read_dam, date_string, $
		dam_spec, dam_time, dam_freqs
	
	;dam_tim0 = anytim(file2time(time0), /time_only, /trun, /yoh)
	;dam_tim1 = anytim(file2time(time1), /time_only, /trun, /yoh)
	;dam_spec = slide_backsub(dam_spec, dam_time, 15.0*60.0, /minimum)	
	;dam_spec = simple_pass_filter(dam_spec, dam_time, dam_freqs, /low_pass, /time_axis, smoothing=10)	


	;***********************************;
	;		    Read Orfees
	;***********************************;
	restore, orfees_folder+'orf_'+date_string+'_bsubbed_minimum.sav', /verb
		orf_spec = orfees_struct.spec
		orf_time = orfees_struct.time
		orf_freqs = reverse(orfees_struct.freq)


	;***********************************;
	;		   Read Ondrejov
	;***********************************;
	file0='~/Data/2014_apr_18/radio/ondrejov/RT5_20140418_124200_130900.fit'
	;file1='~/Data/2014_apr_18/radio/ondrejov/B1404181b.FTS'
	mreadfits, file0, hdr0, data0 
	;mreadfits, file1, hdr1, data1 
	ond_times0 = anytim('2014-04-18T'+hdr0.time_d$obs, /utim) + dindgen(hdr0.naxis1)*hdr0.integ/100.
	;ond_times1 = anytim('2014-04-18T'+hdr1.time1, /utim) + dindgen(hdr1.naxis1)*hdr0.integ/100.

	ond_spec = reverse(data0,2);, data1]
	ond_spec = alog10(ond_spec)
	ond_spec = ond_spec/max(ond_spec)
	ond_times = ond_times0;, ond_times1]
	ond_freqs = reverse(interpol([800, 2000], hdr0.naxis2))



	;***********************************;
	;			   PLOT
	;***********************************;	

	;plot_spec, dam_spec, dam_time, dam_freqs, [freq0, freq1], [time0, time1], scl0=0.07, scl1=0.4, plt_pos=pos0
	plot_spec, orf_spec, orf_time, orf_freqs, [freq0, freq1], [time0, time1], scl0=-0.1, scl1=1.2, plt_pos=pos0
	plot_spec, ond_spec, ond_times, ond_freqs, [freq0, freq1], [time0, time1], scl0=0.7, scl1=0.95, plt_pos=pos0
	


	;!p.thick=4
	;set_line_color
	;plots, [time_marker, time_marker], [freq0, freq1], thick=2, color=10, /data


stop
	loadct, 0
	window, 1
	trange = anytim(file2time([time0, time1]), /utim)
	freq_array = reverse(orf_freqs)
	index = closest(freq_array, 210)
	lcurve = orf_spec[*, index]
	utplot, orf_time, lcurve, $
		/xs, $
		/ys, $
		;/ylog, $
		linestyle = 0, $
		;color = 1, $
		;xticklen=-1e-5, $
		;yticklen=-1e-5, $
		ytitle = ' ', $
		xtitle = ' ', $
		thick=1, $
		;ytickformat='(A1)', $
		;xtickformat='(A1)', $
		position = pos0, $
		xr = trange, $
		;yr=[0.1, 1.5], $
		/normal, $
		/noerase

	

END
