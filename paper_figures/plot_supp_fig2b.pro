pro setup_ps, name
  
  set_plot,'ps'
  !p.font=0
  !p.charsize=1.0
  !p.thick=4
  device, filename = name, $
          /color, $
          /helvetica, $
          /inches, $
          xsize=6, $
          ysize=6, $
          /encapsulate, $
          yoffset=5

end

pro plot_supp_fig2b, postscript=postscript

	; Code to plot the total intensity of the x-point in various AIA filters.
	; The intensities were produced from aia_sum_int_20140418.pro

	

	files = file_search('~/Data/2014_apr_18/pulsations/xpoint_intensity/*pulse_region*.sav')
	filters = ['9.4', '13.1', '17.1', '19.3', '21.1', '33.5']
	set_line_color
	colors = [4, 10, 2, 6, 7, 5]
	psyms =[0,1,2,4,5,6]

	if keyword_set(postscript) then begin
		 setup_ps, '~/aia_flux_20140418.eps'
	endif else begin	 
		window, 0, xs=600, ys=500
	endelse	

	for i=0, n_elementS(files)-1 do begin
		restore, files[i]
		if i eq 0 then begin
			flux_data_sum=flux_data_sum/max(flux_data_sum)
			indices=where(flux_data_sum lt 0.935)
			
			for j=0, 3 do begin
				index = indices[j]
				flux_data_sum[index-2:index+2] = flux_data_sum[index-2]
			endfor	

			utplot, times, flux_data_sum/max(flux_data_sum), $
				psym=psyms[i], $
				xr=trange, $
				yr=[0.9, 1.01], $
				color=0, $
				/noerase, $
				ytitle = 'Normalised integrated AIA flux'
			outplot, times, flux_data_sum/max(flux_data_sum), color=colors[i]
		endif else begin	 	
			outplot, times, flux_data_sum/max(flux_data_sum), color=0
			outplot, times, flux_data_sum/max(flux_data_sum), color=colors[i]
		endelse
	endfor

	legend, filters+' nm', colors=colors, linestyle=[0,0,0,0,0,0], box=0, /bottom, /left

	if keyword_set(postscript) then device, /close
	set_plot, 'x'


END