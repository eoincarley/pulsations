pro aia_process_fig1, img_name, img_pre_name, hdr, hdr_pre, $
         iscaled_img, im_type, imsize = imsize

        ; Perform the image intensity scaling etc for Figure 1

        aia_prep, img_pre_name, -1, hdr_pre, img_pre, /uncomp_delete, /norm
        aia_prep, img_name, -1, hdr, img, /uncomp_delete, /norm

        ;img_pre = img_pre/hdr_pre.exptime
        ;img = img/hdr.exptime

        if im_type eq 'nrgf' then begin
            iscaled_img = img/img_pre
            undefine, img
            undefine, img_pre
            read_sdo, img_name, hdr, junk, outsize=4096
            iscaled_img = rebin(iscaled_img, imsize, imsize)
            remove_nans, iscaled_img, iscaled_img, /return_img
            iscaled_img = disk_nrgf_3col_ratio(iscaled_img, hdr, 0, 0, rsub = rsub, rgt=rgt)
            iscaled_img[rsub] = iscaled_img[rsub]*5.0 > (-4.0) < 4.0   
            iscaled_img[rgt] = iscaled_img[rgt] > (-6.0) < 4.0 

            ;hfreq = iscaled_img - smooth(iscaled_img, 30)
            ;iscaled_img = iscaled_img*0.5 + hfreq

            iscaled_img = filter_image(iscaled_img, /median)
        endif 

        if im_type eq 'total_b' then begin
            iscaled_img = img
            undefine, img
            undefine, img_pre
            iscaled_img = ( iscaled_img - mean(iscaled_img) ) /stdev(iscaled_img)   

            ;iscaled_img = alog(iscaled_img>1e-6)
            ;iscaled_img = iscaled_img > ;(-20) < (28)    ;and 28 good for pre-eruptive rope.
            hfreq = iscaled_img - smooth(iscaled_img, 3)
            iscaled_img = 0.3*iscaled_img + 2.5*hfreq
            iscaled_img = iscaled_img > (-0.2) < 1.5  ; -1, 6 

            ;iscaled_img = iscaled_img > (-6) < 1  ; -1, 6 
        endif   

        if im_type eq 'ratio' then begin
            iscaled_img = img/img_pre;smooth(img, 2)/smooth(img_pre, 2)
            undefine, img
            undefine, img_pre
            iscaled_img = iscaled_img > (0.85) < 1.12;> (0.5) < 1.3; ;>(0.7) < 1.2 ;    ;0.80, 1.5 for ratio image
            ;iscaled = smooth(iscaled_img, 5)
            ;hfreq = iscaled_img - smooth(iscaled_img, 10)
            ;iscaled_img = iscaled_img + 0.1*hfreq
        endif   

 

END
