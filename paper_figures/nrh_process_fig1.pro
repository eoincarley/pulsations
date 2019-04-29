pro nrh_process_fig1, tstart, freq_tags=freq_tags, back_sub=back_sub

	;				PLOT NRH
	;tstart = anytim(aia_hdr.date_obs, /utim) 
	;NOTE: doesn't necessarily have to be an AIA three colour that the contours are overplotted onto.
	;	   It simly plots onto a map.
	  
	tstart = anytim(tstart, /utim) ;- 7.0  

	folder = '~/Data/2014_apr_18/radio/nrh/clean_wresid/'
	cd, folder
	nrh_filenames = (findfile('*.fts'))
							;[10,	9,	 8,	  7,   6,	5,	 4,	  3,	2]
							;[445, 432, 408, 327, 298, 270, 228, 173, 150]

	
	colors = [7] ;reverse([5,6,7])	;reverse([6,8,4,10])	;[2, 3, 7, 10] ;(indgen(9)+2.)
					;colors = [6, 7, 10]
	inds = [2] ;reverse([2,4,5])	;reverse([5,6,7,8])		;[0, 1, 5, 7] ;indgen(9)
	for j=0, n_elements(inds)-1 do begin
		
		;tstart =  anytim('2014-04-18T13:09:35', /utim); anytim(aia_hdr.date_obs, /utim) ;anytim('2014-04-18T12:35:11', /utim)
		t0 = anytim(tstart, /yoh, /trun, /time_only)
		nrh_file_index = inds[j]

					if keyword_set(back_sub) then begin
						t0pre = anytim('2014-09-01T10:55:00', /utim)	; This time range is pre-event for the 2014-09-01 event
						t1pre = anytim('2014-09-01T10:55:00', /utim)+20.0
						t0 = anytim(t0pre, /yoh, /trun, /time_only)
						t1 = anytim(t1pre, /yoh, /trun, /time_only)

						read_nrh, nrh_filenames[nrh_file_index], $	; 432 MHz
								nrh_hdr, $
								nrh_data_pre, $
								hbeg=t0, $
								hend=t1	

						nrh_data_pre = smooth(mean(nrh_data_pre, dim=3), 20)		

					endif			

		t0 = anytim(tstart, /yoh, /trun, /time_only)
		read_nrh, nrh_filenames[nrh_file_index], $	; 432 MHz
				nrh_hdr, $
				nrh_data, $
				hbeg=t0	
			

		if keyword_set(back_sub) then nrh_data = nrh_data - nrh_data_pre			
							
		index2map, nrh_hdr, nrh_data, $
				 nrh_map  

		freq_tag = string(nrh_hdr.freq, format='(I3)')		 
		nrh_data = smooth(nrh_data, 5)
		;nrh_data = alog10(nrh_data)
		nrh_map.data = nrh_data	
		;data_roi = nrh_data[0:32, 64:127]  ;nrh_data[64:127, 0:64] 	;nrh_data[0:32, 64:127] 	; For determinging source max for 2014-04-18 event
		max_val =max( (nrh_data) ,/nan) 							   
		nlevels=5.0   

		top_percent = 0.5	; 0.3 on a linear scale for the 2014 Sep 01 event

		;if nrh_hdr.freq gt 175 then threshold = 3e6 else threshold = 1e8	; for the 2014 Sep 01 event.
		

		levels = (dindgen(nlevels)*(max_val - max_val*top_percent)/(nlevels-1.0)) $
					+ max_val*top_percent  ;> threshold	

		;levels = (dindgen(nlevels)*(10^9. - 10^8.0)/(nlevels-1.0)) $
		;			+ 10^8.0	

		max_inds = where(nrh_map.data eq max(nrh_map.data))
		max_inds_xy = array_indices(nrh_map.data, max_inds)


		set_line_color
		plot_map, nrh_map, $
			/overlay, $
			/cont, $
			/noerase, $
			levels=levels, $
			;/noxticks, $
			;/noyticks, $
			/noaxes, $
			thick=15, $
			color=1

		;if j eq 0 then plot_helio, nrh_hdr.date_obs, $
		;	/over, $
		;	gstyle=0, $
		;	gthick=3.0, $	
		;	gcolor=255, $
		;	grid_spacing=15.0


		set_line_color
		plot_map, nrh_map, $
			/overlay, $
			/cont, $
			levels=levels, $
			/noxticks, $
			/noyticks, $
			/noaxes, $
			thick=10, $
			color=colors[j]					 

		print, 	'NRH time: '+anytim(nrh_hdr.date_obs, /cc)+' UT'
		print, 'Brightness temperature max at '+freq_tag+'  MHz: '+string(levels)
		print, 'Frequency: '+freq_tag+' MHz '+'. Color: '+string(j+2)
		print, '--------'

		xpos_nrh_lab = 0.15
		ypos_nrh_lab = 0.84

		if keyword_set(freq_tags) then begin
			if j eq n_elements(inds)-1 then begin
				xyouts, xpos_nrh_lab+0.0021, ypos_nrh_lab - (j)/38.0, 'NRH '+freq_tag+' MHz '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', color=0, /normal
				xyouts, xpos_nrh_lab-0.0021, ypos_nrh_lab - (j)/38.0, 'NRH '+freq_tag+' MHz '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', color=0, /normal
				xyouts, xpos_nrh_lab, ypos_nrh_lab - (j)/38.0, 'NRH '+freq_tag+' MHz '+anytim(nrh_hdr.date_obs, /cc, /trun)+' UT', color=colors[j], /normal 
			endif else begin
				xyouts, xpos_nrh_lab+0.0021, ypos_nrh_lab - (j)/38.0, 'NRH '+freq_tag+' MHz ', /normal, color=1
				xyouts, xpos_nrh_lab-0.0021, ypos_nrh_lab - (j)/38.0, 'NRH '+freq_tag+' MHz ', /normal, color=1
				xyouts, xpos_nrh_lab, ypos_nrh_lab - (j)/38.0, 'NRH '+freq_tag+' MHz ', /normal, color=colors[j]
			endelse
		endif		

	endfor						 

 END