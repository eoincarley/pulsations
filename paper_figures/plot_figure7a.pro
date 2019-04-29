pro setup_ps, name, xsize, ysize

    set_plot,'ps'
    !p.font=0
    !p.charsize=1.5
    device, filename = name, $
        ;/decomposed, $
        /color, $
        /helvetica, $
        /inches, $
        xsize=10, $;xsize/100, $
        ysize=10, $;xsize/100, $
        /encapsulate, $
        bits_per_pixel=32;, $
       ; yoffset=5

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

;--------------------------------------------------------------------;
;
;			        Routine to plot three-color AIA images. 
;
;--------------------------------------------------------------------;

pro plot_figure7a, date = date, xwin = xwin, $
            zoom=zoom, parallelise=parallelise, winnum=winnum, $
            hot = hot, postscript=postscript, im_type=im_type, folder=folder

;+++
;    NAME:
;    Adapted from aia_three_color. To plot Figure 7a of pulsations paper:
;    plot_figure7a, date = '2014-04-18', /xwin, /zoom, im_type='total_b', /hot
;
;    PROJECT:
;    ELEVATE Catalogue
;
;    PURPOSE:
;    This code plots an AIA three color image, e.g., three AIA filters in an RGB image.
;
;    CALLING SEQUENCE:
;    aia_three_color, date = '2014-04-18', /xwin, /zoom, im_type='ratio'
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
        FOV = [25.0, 25.0]  ;[25.0, 25.0] ;[20, 20]  ;[27.15, 27.15]    ;  [40., 40.]   ;[16.0, 16.0]    ;   [10, 10]  ;[16.0, 16.0]  ;[10, 10]    ;[27.15, 27.15];
        CENTER = [0, -200] ;[150, -200]  ;[450, -450] ;[-1100, 400]    ;[500, -350]    ;  [-900., 0.] ;[550, -230]  ;[600.0, -220] ;[500.0, -230]  ;[600.0, -220] ; 
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
        x_size = 2048
        y_size = 2048
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
    n_array = [0,1,2]


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
    endif else begin     
        ;set_plot, 'z'
        ;!p.multi = 0
        ;img = fltarr(3, x_size+border, x_size+border)
        ;device, set_resolution = [x_size+border, x_size+border], set_pixel_depth=24, decomposed=0
    endelse


        ;restore, '~/Data/2014_apr_18/pulsations/nrh_228_pulse_src_props_hires_si.sav', /verb  
        ;times = anytim(xy_arcs_struct.times, /utim)
        ;xarcs = xy_arcs_struct.x_max_fit
        ;yarcs = xy_arcs_struct.y_max_fit
    ;-------------------------------------------------;
    ;        *********************************
    ;             Image Loop starts here
    ;        *********************************
    ;-------------------------------------------------;

    first_img_index = closest(min_tim, anytim('2014-04-18T12:55:36', /utim))
    last_img_index = closest(min_tim, anytim('2014-04-18T018:35:00', /utim))

        ; 161 for type III image of initial flare. 188 for type IIIs. For 2014-Apr-18 Event. 
        ; 190 on cool AIA channels for good CME legs.
        ; 185 for detached EUV wave

    img_num = first_img_index
    for i = first_img_index, last_img_index do begin  
      
        get_utc, start_loop_t, /cc

        IF keyword_set(parallelise) THEN BEGIN
            ;---------- Run processing of three images in parallel using IDL bridges -------------;
            pref_set, 'IDL_STARTUP', '/Users/eoincarley/idl/.idlstartup', /commit             
            oBridge1 = OBJ_NEW('IDL_IDLBridge', output='/Users/eoincarley/child1_output.txt') 
            oBridge1->EXECUTE, '@' + PREF_GET('IDL_STARTUP')   ;Necessary to define startup file because child process has no memory of ssw_path of parent process
            oBridge1->SetVar, 'fls_211', fls_211
            oBridge1->SetVar, 'fls_193', fls_193
            oBridge1->SetVar, 'fls_171', fls_171
            oBridge1->SetVar, 'i', i

            oBridge2 = OBJ_NEW('IDL_IDLBridge')
            oBridge2->EXECUTE, '@' + PREF_GET('IDL_STARTUP')
            oBridge2->SetVar, 'fls_211', fls_211
            oBridge2->SetVar, 'fls_193', fls_193
            oBridge2->SetVar, 'fls_171', fls_171
            oBridge2->SetVar, 'i', i

            oBridge3 = OBJ_NEW('IDL_IDLBridge')
            oBridge3->EXECUTE, '@' + PREF_GET('IDL_STARTUP') 
            oBridge3->SetVar, 'fls_211', fls_211
            oBridge3->SetVar, 'fls_193', fls_193
            oBridge3->SetVar, 'fls_171', fls_171
            oBridge3->SetVar, 'i', i

            oBridge1 -> Execute, 'aia_process_image, fls_211[i], fls_211[i-5], i_a, i_a_pre, iscaled_a, im_type, imsize = array_size', /nowait

            oBridge2 -> Execute, 'aia_process_image, fls_193[i], fls_193[i-5], i_b, i_b_pre, iscaled_b, im_type, imsize = array_size', /nowait

            oBridge3 -> Execute, 'aia_process_image, fls_171[i], fls_171[i-5], i_c, i_c_pre, iscaled_c, im_type, imsize = array_size', /nowait

            print, 'Waiting for child processes to finish.'
            WHILE (oBridge1->Status() EQ 1 or oBridge2->Status() EQ 1 or oBridge3->Status() EQ 1) DO BEGIN
                junk=1
            ENDWHILE

            return_struct, oBridge1, 'i_a', i_a
            return_struct, oBridge2, 'i_b', i_b
            return_struct, oBridge3, 'i_c', i_c

            iscaled_a = oBridge1->GetVar('iscaled_a')
            iscaled_b = oBridge2->GetVar('iscaled_b')
            iscaled_c = oBridge3->GetVar('iscaled_c')

        ENDIF ELSE BEGIN
            ;Simply runs processing in series, as opposed to parallel
            aia_process_image, fls_211[i], fls_211[i-5], i_a, i_a_pre, iscaled_a, im_type, imsize = array_size
            aia_process_image, fls_193[i], fls_193[i-5], i_b, i_b_pre, iscaled_b, im_type, imsize = array_size
            aia_process_image, fls_171[i], fls_171[i-5], i_c, i_c_pre, iscaled_c, im_type, imsize = array_size
        ENDELSE
     
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
        ; aia_lct,r,g,b,wavelnth=171,load=load
        loadct, 0
        if keyword_set(postscript) then $
            ;setup_ps, '~/Data/2014_apr_18/pulsations/aia171_x_zoom_'+string(img_num-first_img_index, format='(I03)' )+'.eps', x_size+border, y_size+border
            setup_ps, '~/Desktop/image_'+string(img_num-first_img_index, format='(I03)' )+'.eps', x_size+border, y_size+border
            img[*, *, 1]=img[*, *, 2]*0.5 + img[*, *, 0]*0.5
            plot_image, img[*, *, *], $
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
            read_sdo, fls_211[i], i_0, d_0, outsize=4096
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
                 gthick=4, $  
                 gcolor=1, $
                 grid_spacing=15.0 

            ; oplotter here    
            ;stamp_date, i_a, i_b, i_c
            oplot_gcircles_20140418,  i_c
            oplot_nrh_on_three_color,  i_c.date_obs;, /freq_tags;, /back_sub            ; For the 2014-April-Event
            
            restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'
            for i=0, n_elements(xlines_total)-1 do begin
              ;plots, xlines, ylines, col=0, thick=8
              xlines = XLINES_TOTAL[i]
              ylines = YLINES_TOTAL[i]
              plots, xlines<700, ylines>(-942), col=0, thick=5.5
              plots, xlines<700, ylines>(-942), col=1, thick=4.5
              plots, xlines<700, ylines>(-942), col=10, thick=3.5

            endfor      

        if keyword_set(postscript) then begin
            device, /close
            set_plot, 'x'
        endif    
stop
        cd, folder  ;change back to aia folder
     
        if keyword_set(xwin) then x2png, folder+'/image_'+string(img_num-first_img_index, format='(I03)' )+'.png'
       

        if keyword_set(zbuffer) then begin
            img = tvrd(/true)
            image_loc_name = folder + '/image_'+string(i-first_img_index, format='(I03)' )+'.png' 
            cd, '~'
            write_png, image_loc_name , img
        endif

        img_num = img_num + 1

        skip_img: print, 'Images too far spaced in time.'

        get_utc, end_loop_t, /cc
        loop_time = anytim(end_loop_t, /utim) - anytim(start_loop_t, /utim)
        print,'-------------------'
        print,'Currently '+string(loop_time, format='(I04)')+' seconds per 3 color image.'
        print,'-------------------'

    endfor
stop
    ;front_pos = transpose(front_pos)
    ;front_pos = {name:'front_xy', times:times, xarcsec:front_pos[0, *], yarcsec:front_pos[1, *]}
    ;save, front_pos, filename= folder+'/euv_front_pos_struct.sav'
    
    date = time2file(i_a.t_obs, /date_only) 
    type0 = 'totB'
    if keyword_set(hot) then chans = 'hot' else chans = 'cool'
    movie_type = 'flux_rope_3col_'+type0+'_'+chans ;else movie_type = '3col_ratio' cd, folder
    ;print, folder 
    ;spawn, '
    ;spawn, 'ffmpeg -y -r 25 -i image_%03d.png -vb 50M AIA_'+date+'_'+movie_type+'.mpg'

    ;spawn, 'cp AIA_'+date+'_'+movie_type+'.mpg ~/Dropbox/sdo_movies/'
    ;spawn, 'cp image_000.png ~/Dropbox/sdo_movies/'
    ;spawn, 'rm -f image*.png'

    files_missing: print,'Files missing for : '+date

END

;******************************************************************;
;
; Routines for overplotting various things, depending on the event.
;
;
;nrh_src_pos_20140901 

;oplot_gcircles_20140418, i_c            
;oplot_nrh_on_three_color,  i_c.date_obs;, /freq_tags;, /back_sub            ; For the 2014-April-Event
;oplot_nrh_on_three_color, '2014-04-18T12:55:32.190'   ;   i_c.date_obs      ;For the 2014-April-Event
;oplot_nrh_on_three_color, '2014-04-18T12:35:11'       ;   For initial type III   

;oplot_pfss_20140418    

;point, x, y, /data
;save, x, y, filename='~/Data/2014_apr_18/sdo/points_faintloop2.sav' 
;dam_orfees_plot_gen, time_marker=anytim(i_c.date_obs, /utim)
;restore,'~/Data/2014_apr_18/sdo/points_faintloop2.sav' 
;plots, x, y, /data, psym=1, color=5, thick=16, symsize=3.0
;plots, x, y, /data, psym=1, color=1, thick=6.0, symsize=2.0

;cursor, x_pos, y_pos, /data 
;if i eq first_img_index then begin
; times = anytim(i_a.date_d$obs, /utim)
; front_pos = [[x_pos] , [y_pos]] 
;endif else begin
; times = [times, anytim(i_a.date_d$obs, /utim)]
; front_pos = [ front_pos, [[x_pos] , [y_pos]]]
;endelse  

;nrh_oplot_pulse_src_pos, anytim(i_c.date_obs, /utim)
;oplot_hmi_map_20140418

;plotsym, 0, /fill
;colors = findgen(n_elements(xarcs))*(255)/(n_elements(xarcs)-1)
;for i=0, n_elements(xarcs)-1 do begin
;  set_line_color
;  plots, xarcs[i], yarcs[i], psym=8, color=0, symsize=1.1, thick=2
;  plots, xarcs[i], yarcs[i], psym=8, color=1, symsize=1.0, thick=2
;  loadct, 16, /silent
;  plots, xarcs[i], yarcs[i], psym=8, color=colors[i], symsize=0.9, thick=2
;endfor  
;set_line_color
;plots, mean(xarcs), mean(yarcs), color=1, psym=1, symsize=3, thick=10
;plots, mean(xarcs), mean(yarcs), color=6, psym=1, symsize=3, thick=5

;loadct, 0
;restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418.sav'
;for i=0, n_elements(xlines_total)-1 do begin
;  xlines = XLINES_TOTAL[i]
;  ylines = YLINES_TOTAL[i]
;  plots, xlines>(-310)<110, ylines>(-460)<(-40), col=50, thick=1.5
;  plots, xlines>(-310)<110, ylines>(-460)<(-40), col=200, thick=1.0
  ;plots, xlines>(-365)<365, ylines>(-610)<(110), col=200, thick=1.5
;endfor

;restore, '~/Data/2014_apr_18/pulsations/pfss_line_QAR_20140418_dense.sav'
;for i=0, n_elements(xlines_total)-1, 1 do begin
;  xlines = XLINES_TOTAL[i]
;  ylines = YLINES_TOTAL[i]
;  plots, xlines>(-310)<110, ylines>(-460)<(-40), col=50, thick=1.5
;  plots, xlines>(-310)<110, ylines>(-460)<(-40), col=200, thick=1.0
  ;plots, xlines>(-365)<365, ylines>(-610)<(110), col=200, thick=1.5
;endfor
;oplot_pfss_20140418         

;stamp_date, i_a, i_b, i_c
