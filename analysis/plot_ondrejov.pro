pro plot_ondrejov


	window, 0, xs=1400, ys=800
	!p.charsize=1.5
	loadct, 3
	reverse_ct

	time_start = anytim('2014-04-18T12:54:00', /utim)
	time_end = anytim('2014-04-18T12:58:00', /utim)

	file0='~/Data/2014_apr_18/radio/ondrejov/B1404181a.FTS'
	file1='~/Data/2014_apr_18/radio/ondrejov/B1404181b.FTS'
	mreadfits, file0, hdr0, data0 
	mreadfits, file1, hdr1, data1 
	times0 = anytim('2014-04-18T'+hdr0.time1, /utim) + dindgen(hdr0.naxis1)*hdr0.integ/100.
	times1 = anytim('2014-04-18T'+hdr1.time1, /utim) + dindgen(hdr1.naxis1)*hdr0.integ/100.

	data =[data0, data1]
	times = [times0, times1]
	freqs = reverse(interpol([800, 2000], hdr0.naxis2))

	spectro_plot, sigrange(data), times, freqs, $
		/xs, $
		/ys, $
		xr=[time_start, time_end], $
		ytitle='Frequency (MHz)'

stop
END