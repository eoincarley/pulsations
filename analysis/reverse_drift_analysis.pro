pro plot_spec, data, time, freqs, frange, trange, scl0=scl0, scl1=scl1
    

    print, 'Processing: '+string(freqs[0], format=string('(I4)')) + $
            ' to ' + $
            string(freqs[n_elements(freqs)-1], format=string('(I4)'))+ ' MHz'


    spectro_plot, data> (scl0) < (scl1), $
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
                position = [0.1, 0.1, 0.9, 0.92], $
                xticklen = -0.001, $
                yticklen = -0.005, $
                lxtickformat='(A1)', $
                xtitle = ' '
        
    
END


pro reverse_drift_analysis

    window, 1, xs=1000, ys=500
	time_start = anytim('2014-04-18T12:55:20') ;
    time_end = anytim('2014-04-18T12:55:40') ;

    
    trange=[time_start, time_end]
    freq = 208

	orfees_folder = '~/Data/2014_apr_18/radio/orfees/'
    freq0 = 200
    freq1 = 340

    date_string = time2file(trange[0], /date)

    restore, orfees_folder+'orf_'+date_string+'_bsubbed_median.sav', /verb
    orf_spec = smooth(orfees_struct.spec, 3)
    orf_time = orfees_struct.time
    orf_freqs = orfees_struct.freq

    ;***********************************;
    ;              PLOT
    ;***********************************;   

    loadct, 74, /silent
    reverse_ct
    plot_spec, orf_spec, orf_time, reverse(orf_freqs), [freq0, freq1], trange, scl0=-0.01, scl1=0.45

stop

END