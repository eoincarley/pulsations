pro setup_ps, name, xsize, ysize

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.4
    device, filename = name, $
        ;/decomposed, $
        /color, $
        /helvetica, $
        /inches, $
        xsize=xsize/100, $
        ysize=xsize/100, $
        /encapsulate, $
        bits_per_pixel=32, $
        yoffset=5

end

pro return_struct, bridge, struct_name, struct

      ; IDL bridges cannot pass structures I/O. This procedure works around that.

      tag_namess = bridge->GetVar('tag_names('+struct_name+')') 
      first_val = bridge->GetVar(struct_name+'.(0)')
      first_tag = tag_namess[0]
      struct = CREATE_STRUCT(NAME=struct_name, first_tag, first_val)
      for i =1, n_elements(tag_namess)-2 do begin
         append_name = tag_namess[i]
         append_value = bridge->GetVar(struct_name+".("+strcompress(string(i), /remove_all)+")")
         struct = CREATE_STRUCT(struct, append_name, append_value)
      endfor

END

pro stamp_date, i_a, i_b, i_c
   
    set_line_color
    xpos_aia_lab = 0.15
    ypos_aia_lab = 0.78  ; 0.78 for top of the frame, 0.15 for bottom


    ;device, /medium     ; Done three times here to create a black background to the letters. Unfortunately charthick does not work with postscript fonts.
    xyouts, xpos_aia_lab-0.0021, ypos_aia_lab+0.06, 'AIA '+string(i_a.wavelnth, format='(I03)') +' A '+anytim(i_a.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=4
    xyouts, xpos_aia_lab+0.0021, ypos_aia_lab+0.06, 'AIA '+string(i_a.wavelnth, format='(I03)') +' A '+anytim(i_a.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=4
    xyouts, xpos_aia_lab, ypos_aia_lab+0.06, 'AIA '+string(i_a.wavelnth, format='(I03)') +' A '+anytim(i_a.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 3.0

    xyouts, xpos_aia_lab-0.0021, ypos_aia_lab+0.03, 'AIA '+string(i_b.wavelnth, format='(I03)') +' A '+anytim(i_b.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=4
    xyouts, xpos_aia_lab+0.0021, ypos_aia_lab+0.03, 'AIA '+string(i_b.wavelnth, format='(I03)') +' A '+anytim(i_b.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=4
    xyouts, xpos_aia_lab, ypos_aia_lab+0.03, 'AIA '+string(i_b.wavelnth, format='(I03)') +' A '+anytim(i_b.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 4

    xyouts, xpos_aia_lab-0.0021, ypos_aia_lab, 'AIA '+string(i_c.wavelnth, format='(I03)') +' A '+anytim(i_c.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=4
    xyouts, xpos_aia_lab+0.0021, ypos_aia_lab, 'AIA '+string(i_c.wavelnth, format='(I03)') +' A '+anytim(i_c.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 0, charthick=4
    xyouts, xpos_aia_lab, ypos_aia_lab, 'AIA '+string(i_c.wavelnth, format='(I03)') +' A '+anytim(i_c.t_obs, /cc, /trun)+ ' UT', alignment=0, /normal, color = 10


END

function make_zoom_struct, fov, center, hdr, downsize

    arcs_per_pixx = hdr.cdelt1/downsize
    arcs_per_pixy = hdr.cdelt2/downsize
    naxisx = hdr.naxis1*downsize
    naxisy = hdr.naxis1*downsize

    x0 = fix((center[0]/arcs_per_pixx + (naxisx/2.0)) - (fov[0]*60.0/arcs_per_pixx)/2.0)
    x1 = fix((center[0]/arcs_per_pixx + (naxisx/2.0)) + (fov[0]*60.0/arcs_per_pixx)/2.0)
    y0 = fix((center[1]/arcs_per_pixy + (naxisy/2.0)) - (fov[1]*60.0/arcs_per_pixy)/2.0)
    y1 = fix((center[1]/arcs_per_pixy + (naxisy/2.0)) + (fov[1]*60.0/arcs_per_pixy)/2.0)

    ; The following produces a new array (bigger or smaller, depending on the zoom size) in which
    ; the original AIA frame is to be inserted. The if statements basically take care of whether or
    ; not the new array is smaller or bigger than the original AIA image. This took fucking ages....

    new_x_size = x1 - x0 + 1
    new_y_size = y1 - y0 + 1
    new_array_a = fltarr(new_x_size, new_y_size)
    new_array_b = fltarr(new_x_size, new_y_size)
    new_array_c = fltarr(new_x_size, new_y_size)

    if x0 lt 0 then begin
        x0new=fix(abs(x0))
        if new_x_size gt naxisx then x1new=abs(x0) + (x1 < (naxisx-1)) $
            else x1new = new_x_size - 1.
    endif else begin
        x0new=0
        x1new=(x1<(naxisx-1)) - (x0>0)
    endelse

    if y0 lt 0 then begin
        y0new=fix(abs(y0))
        if new_x_size gt naxisx then y1new=abs(y0) + (y1 < (naxisx-1)) $
            else y1new = new_x_size - 1.
    endif else begin
        y0new=0
        y1new=(y1<(naxisx-1)) - (y0>0)
    endelse 

    x_range = [x0, x1]  
    y_range = [y0, y1]    

    if (x_range[1]-x_range[0]) gt 1024 or (y_range[1]-y_range[0]) gt 1024 then begin
        if (x_range[1]-x_range[0]) ge (y_range[1]-y_range[0]) then begin
            x_size = 1024
            y_size = round(1024*(float(y_range[1]-y_range[0])/float(x_range[1]-x_range[0])))
        endif
        if (x_range[1]-x_range[0]) lt (y_range[1]-y_range[0]) then begin
            y_size = 1024
            x_size = round(1024*(float(x_range[1]-x_range[0])/float(y_range[1]-y_range[0])))
        endif
    endif else begin
        x_size = (x_range[1]-x_range[0])
        y_size = (y_range[1]-y_range[0])
    endelse        

    zoom_struct = { name:'zoom_struct', $
                    aia_pix_coords:[x0, x1, y0, y1], $
                    zoom_pix_coords:[x0new, x1new, y0new, y1new], $
                    winsz:[x_size, y_size] }  

    return, zoom_struct

END

pro oplot_hmi_map_20140418

    
    restore, '~/Data/2014_apr_18/pulsations/hmi/hmi_map_20140418.sav'
    hmi_map = map

    hmi_data = hmi_map.data
    hmi_data = bytscl(hmi_map.data, -1e2, 0.7e2)

    ;hmi_data = alog10(hmi_data)/max(alog10(hmi_data))
    hmi_data = smooth(hmi_data, 15)

    hmi_data[0:1600, *]=-1e7
    hmi_data[*, 0:1400]=-1e7
    hmi_map.data = hmi_data

    levels = [200]
    
    set_line_color
    plot_map, hmi_map, $
        /overlay, $
        /cont, $
        levels=levels, $
        /noxticks, $
        /noyticks, $
        /noaxes, $
        thick=12, $  ; usually 12, 7
        color=0       

    plot_map, hmi_map, $
        /overlay, $
        /cont, $
        levels=levels, $
        /noxticks, $
        /noyticks, $
        /noaxes, $
        thick=7, $
        color=10             

    levels = [40]

    plot_map, hmi_map, $
        /overlay, $
        /cont, $
        levels=levels, $
        /noxticks, $
        /noyticks, $
        /noaxes, $
        thick=12, $
        color=0        

    plot_map, hmi_map, $
        /overlay, $
        /cont, $
        levels=levels, $
        /noxticks, $
        /noyticks, $
        /noaxes, $
        thick=7, $
        color=4     
             

END

 pro oplot_radio_src_points, freq, color

    restore, '~/Data/2014_apr_18/pulsations/nrh_'+freq+'_pulse_src1_props_hires_si.sav', /verb  
    t0_points = anytim('2014-04-18T12:55:20', /utim)
    times = anytim(xy_arcs_struct.times, /utim)
    xarcs = xy_arcs_struct.x_max_fit
    yarcs = xy_arcs_struct.y_max_fit
    plotsym, 0, /fill
    colors = findgen(n_elements(xarcs))*(255)/(n_elements(xarcs)-1)
    for i=0, n_elements(xarcs)-1 do begin
      if times[i] gt t0_points then begin

        ;plots, xarcs[i], yarcs[i], psym=8, color=0, symsize=1.1, thick=2
        ;plots, xarcs[i], yarcs[i], psym=8, color=1, symsize=1.0, thick=2
        plots, xarcs[i], yarcs[i], psym=8, color=colors[i], symsize=0.6, thick=1
      endif  
    endfor  
    ;set_line_color
    xarcs = xarcs[where(times gt t0_points)]
    yarcs = yarcs[where(times gt t0_points)]
    plots, mean(xarcs), mean(yarcs), color=0, psym=8, symsize=2, thick=10
    plots, mean(xarcs), mean(yarcs), color=100, psym=8, symsize=1, thick=5

END
;--------------------------------------------------------------------;
;
;			        Routine to plot three-color AIA images. 
;
;--------------------------------------------------------------------;

pro plot_figure5a, date = date, xwin = xwin, $
            zoom=zoom, parallelise=parallelise, winnum=winnum, $
            hot = hot, postscript=postscript, im_type=im_type, folder=folder

    ; Adaptation to plot Figure 5a of pulsation paper        

;+++
;    NAME:
;    aia_three_color
;
;    PROJECT:
;    ELEVATE Catalogue
;
;    PURPOSE:
;    This code plots an AIA three color image, e.g., three AIA filters in an RGB image.
;
;    CALLING SEQUENCE:
;    plot_figure5a, date = '2014-04-18', /xwin, /zoom, im_type='total_b'
;    aia_three_color, folder = '~/Data/2014_sep_01/sdo/', /xwin, /zoom, im_type='ratio'
;
;    INPUT:
;    None for the moment, but date='YYYY-MM-DD' will allow data retrieval from the ELEVATE catlogue
;
;    KEYWORDS:
;    date: A string of 'YYYY-MM-DD'. This is to search a folder with such a string 
;          in the ELEVATE catalogue
;    xwin: Plot the image in an xwindow. 
;    winnum: Window number if xwin chosen. Default 0.
;    postscript: Plots in postscript device. May need to play around a little 
;                with charsize for this option
;    zoom: Zooms on a region. User will have to define ROI in the code below.
;    hot: Will plot the 'hot' AIA channels, 94, 131, 335 Anstroms
;    im_type: Chose from 'ratio' for running ratio, 'nrgf' for a running ratio with 
;             a normalising radial gradient filter, or 'total_b' for just total brightness.
;    folder: specificy a folder in which the data folders '171', '193' and '211' are present.
;    parallelise: This will process the three AIA images in parallel using IDL bridges. May or may not
;                 speed up processing time.
;
;
;    HISTORY:
;    2015: Written partially by Eoin Carley
;    2016-March-23: Cleanup, Eoin Carley.  
;-
        
    !p.charsize = 1.5
    if ~keyword_set(im_type) then im_type = 'total_b' 
    if ~keyword_set(winnum) then winnum = 0        
    if keyword_set(folder) then folder = folder else folder = '~/Data/elevate_db/'+date+'/SDO/AIA'


    if keyword_set(hot) then begin
       pass_a = '094'
       pass_b = '131'
       pass_c = '335'

       file_loc_211 = folder + '/094'
       file_loc_193 = folder + '/131'
       file_loc_171 = folder + '/335'
    endif else begin
       pass_a = '211'
       pass_b = '193'
       pass_c = '171'

       file_loc_211 = folder + '/211'
       file_loc_193 = folder + '/193'
       file_loc_171 = folder + '/171'
    endelse

    fls_a = file_search( file_loc_211 +'/*.fits' )
    fls_b = file_search( file_loc_193 +'/*.fits' )
    fls_c = file_search( file_loc_171 +'/*.fits' )
  
    if n_elements(fls_a) lt 5 or n_elements(fls_b) lt 5 or n_elements(fls_c) lt 5 then goto, files_missing

    array_size = 4096
    downsize = 1.0  ; array downsize
    shrink = 1.0   ;shrink image size
    if keyword_set(zoom) then begin
    
        read_sdo, fls_a[0], i_a, /nodata, only_tags='cdelt1,cdelt2,naxis1,naxis2', /mixed_comp, /noshell   
        
        ;FOV = [35.0, 35.0]
        ;CENTER = [-1100.0, 400.0]
        FOV = [6.0, 6.0]  ;[25.0, 25.0] ;[20, 20]  ;[27.15, 27.15]    ;  [40., 40.]   ;[16.0, 16.0]    ;   [10, 10]  ;[16.0, 16.0]  ;[10, 10]    ;[27.15, 27.15];
        CENTER = [-100, -250] ;[150, -200]  ;[450, -450] ;[-1100, 400]    ;[500, -350]    ;  [-900., 0.] ;[550, -230]  ;[600.0, -220] ;[500.0, -230]  ;[600.0, -220] ; 
        zoom_struct = make_zoom_struct(FOV, CENTER, i_a, downsize)

        x0 = zoom_struct.aia_pix_coords[0]
        x1 = zoom_struct.aia_pix_coords[1]
        y0 = zoom_struct.aia_pix_coords[2]
        y1 = zoom_struct.aia_pix_coords[3]
        new_x_size = x1 - x0 + 1
        new_y_size = y1 - y0 + 1
        new_array_a = fltarr(new_x_size, new_y_size)
        new_array_b = fltarr(new_x_size, new_y_size)
        new_array_c = fltarr(new_x_size, new_y_size)

        x0new = zoom_struct.zoom_pix_coords[0]
        x1new = zoom_struct.zoom_pix_coords[1]
        y0new = zoom_struct.zoom_pix_coords[2]
        y1new = zoom_struct.zoom_pix_coords[3]

        x_size = zoom_struct.winsz[0]
        y_size = zoom_struct.winsz[1]                

    endif else begin
        x_size = 1024
        y_size = 1024
    endelse

    border = 400/shrink
    x_size = x_size/shrink
    y_size = y_size/shrink

    ; Check the images to make sure we're not using AEC-affected images
    min_exp_t_193 = 1.0
    min_exp_t_211 = 1.5
    min_exp_t_171 = 1.5

    read_sdo, fls_a, i_a, /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell
    f_a = fls_a[where(i_a.exptime gt min_exp_t_211)]
    t = anytim(i_a.date_d$obs)
    t_a = t[where(i_a.exptime gt min_exp_t_211)]

    read_sdo, fls_b, i_b, /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell
    f_b = fls_b[where(i_b.exptime gt min_exp_t_193)]
    t = anytim(i_b.date_d$obs)
    t_b = t[where(i_b.exptime gt min_exp_t_193)]

    read_sdo, fls_c, i_c, /nodata, only_tags='exptime,date-obs', /mixed_comp, /noshell
    f_c = fls_c[where(i_c.exptime gt min_exp_t_171)]
    t = anytim(i_c.date_d$obs)
    t_c = t[where(i_c.exptime gt min_exp_t_171)]

    t_str_a = anytim(t_a)
    t_str_b = anytim(t_b)
    t_str_c = anytim(t_c)


    ; Now identify images adjacent in time using the smallest array to get
    ; the image times
    arrs = [n_elements(f_a), n_elements(f_b), n_elements(f_c)]
    val = max(arrs, f_max, subscript_min = f_min)
    n_array = [0, 1, 2]


    case f_min of
      0: image_time = t_a
      1: image_time = t_b
      2: image_time = t_c
    endcase

    f_mid = n_array[where(n_array ne f_max and n_array ne f_min)]

    if f_min eq f_max then begin
         max_tim = t_str_a
         mid_tim = t_str_b
         min_tim = t_str_c
    endif else begin
      case f_max of
         0: max_tim = t_str_a
         1: max_tim = t_str_b
         2: max_tim = t_str_c
      endcase
      case f_min of
         0: min_tim = t_str_a
         1: min_tim = t_str_b
         2: min_tim = t_str_c
      endcase
      case f_mid of
         0: mid_tim = t_str_a
         1: mid_tim = t_str_b
         2: mid_tim = t_str_c
      endcase
    endelse


    ; This loop finds the closest file to min_tim[n] for each of the filters. It constructs an
    ; array of indices for each of the filters.
    for n = 0, n_elements(min_tim)-1 do begin
      sec_min = min(abs(min_tim - min_tim[n]),loc_min)
      if n eq 0 then next_min_im = loc_min else next_min_im = [next_min_im, loc_min]

      sec_max = min(abs(max_tim - min_tim[n]),loc_max)
      if n eq 0 then next_max_im = loc_max else next_max_im = [next_max_im, loc_max]

      sec_mid = min(abs(mid_tim - min_tim[n]),loc_mid)
      if n eq 0 then next_mid_im = loc_mid else next_mid_im = [next_mid_im, loc_mid]
    endfor

    if f_min eq f_max then begin
         loc_211 = next_max_im
         loc_193 = next_mid_im
         loc_171 = next_min_im
    endif else begin
      case f_max of
         0: loc_211 = next_max_im
         1: loc_193 = next_max_im
         2: loc_171 = next_max_im
      endcase
      case f_mid of
         0: loc_211 = next_mid_im
         1: loc_193 = next_mid_im
         2: loc_171 = next_mid_im
      endcase
      case f_min of
         0: loc_211 = next_min_im
         1: loc_193 = next_min_im
         2: loc_171 = next_min_im
      endcase
    endelse  

    fls_211 = f_a[loc_211]
    fls_193 = f_b[loc_193]
    fls_171 = f_c[loc_171]
    
    ; Setup plotting parameters  
    if keyword_set(xwin) and ~keyword_set(postscript) then begin
        loadct, 0, /silent  
        window, winnum, xs = (x_size+border), ys = y_size+border, retain=2
        !p.multi = 0
    endif 

    ;-------------------------------------------------;
    ;        *********************************
    ;             Image Loop starts here
    ;        *********************************
    ;-------------------------------------------------;

    index = closest(min_tim, anytim('2014-04-18T12:57:11', /utim))     
      
    aia_process_figure5a, fls_211[index], fls_211[index-5], i_a, i_a_pre, iscaled_a, im_type, imsize = array_size
    aia_process_figure5a, fls_193[index], fls_193[index-5], i_b, i_b_pre, iscaled_b, im_type, imsize = array_size
    aia_process_figure5a, fls_171[index], fls_171[index-5], i_c, i_c_pre, iscaled_c, im_type, imsize = array_size
         
    ; Check that the images are closely spaced in time
    if (abs(anytim(i_a.date_d$obs)-anytim(i_b.date_d$obs)) or $
        abs(anytim(i_a.date_d$obs)-anytim(i_c.date_d$obs)) or $
        abs(anytim(i_b.date_d$obs)-anytim(i_c.date_d$obs))) gt 12. then goto, skip_img

    if keyword_set(zoom) then begin
        image_section_a = iscaled_a[(x0>0):(x1<(array_size-1)), (y0>0):(y1<(array_size-1))]
        image_section_b = iscaled_b[(x0>0):(x1<(array_size-1)), (y0>0):(y1<(array_size-1))]
        image_section_c = iscaled_c[(x0>0):(x1<(array_size-1)), (y0>0):(y1<(array_size-1))]

        new_array_a[*] = mean(iscaled_a)
        new_array_b[*] = mean(iscaled_b)
        new_array_c[*] = mean(iscaled_c)

        new_array_a[x0new:x1new, y0new:y1new] = image_section_a
        new_array_b[x0new:x1new, y0new:y1new] = image_section_b 
        new_array_c[x0new:x1new, y0new:y1new] = image_section_c 
    endif else begin    
        new_array_a = iscaled_a
        new_array_b = iscaled_b
        new_array_c = iscaled_c
    endelse    

    img = [[[new_array_a]], [[new_array_b]], [[new_array_c]]] ;contruct RGB image

    ;---------------------------;
    ;        PLOT IMAGE
    ;---------------------------;

    ;loadct, 65, /silent
    ;reverse_ct
    ;gamma_ct, 0.6

    aia_lct,r,g,b,wavelnth=171,load=load
    loadct, 0
    if keyword_set(postscript) then setup_ps, '~/aia_nrh_pos.eps', x_size+border, y_size+border

        plot_image, img[*, *, 2], $
            position = [border/2, border/2, x_size+border/2, y_size+border/2]/(x_size+border), $
            /normal, $
            xticklen=-0.001, $
            yticklen=-0.001, $
            xtickname=[' ',' ',' ',' ',' ',' ',' ', ' '], $
            ytickname=[' ',' ',' ',' ',' ',' ',' ', ' ']

        ;---------------------------------------------------------------;
        ; In order to plot a heligraphic grid. Overplot an empty dummy 
        ; map of the same size then use plot_helio aia_prep, fls_211[i],
        ; -1, i_0, d_0, /uncomp_delete, /norm
        read_sdo, fls_211[index], i_0, d_0, outsize=4096
        index2map, i_0, d_0, map0
        data = map0.data 
        data = data < 50.0   ; Just to make sure the map contours of the dummy map don't show up.
        map0.data = data
        levels = [100,100,100]


        set_line_color
        plot_map, map0, $
            /cont, $
            levels=levels, $
            ; /noxticks, $
            ; /noyticks, $
            ; /noaxes, $
            ;thick=1.5, $
            color=0, $
            position = [border/2, border/2, x_size+border/2, y_size+border/2]/(x_size+border), $ 
            /normal, $
            /noerase, $
            title = i_c.date_obs, $
            xticklen=-0.01, $
            yticklen=-0.01, $
            fov = FOV, $
            center = CENTER  

        plot_helio, i_0.date_obs, $
             /over, $
             gstyle=1, $
             gthick=1, $  
             gcolor=1, $
             grid_spacing=15.0 

      ;oplot_hmi_map_20140418         

      ;oplot_radio_src_points, '408', 61
      loadct, 52, /silent
      gamma_ct, 2.28
      oplot_radio_src_points, '327', 52 ; Blue

      loadct, 53, /silent
      gamma_ct, 2.0
      oplot_radio_src_points, '298', 53 ; Green
      ;oplot_radio_src_points, '270', 57 ; Blue

      loadct, 56, /silent
      gamma_ct, 1.0
      oplot_radio_src_points, '228', 56 ; Red
     

    if keyword_set(postscript) then begin
        device, /close
        set_plot, 'x'
    endif    

    skip_img: print, 'Images too far spaced in time.'

    files_missing: print,'Files missing for : '+date

END

