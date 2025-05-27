function z_fi_zrfi028n.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_VKORG) TYPE  VKORG OPTIONAL
*"     REFERENCE(I_NOSLET) TYPE  XFELD DEFAULT ' '
*"     REFERENCE(I_TOPNIV) TYPE  XFELD DEFAULT 'X'
*"     REFERENCE(I_DECIMA) TYPE  ZZANT_DEC DEFAULT '2'
*"     REFERENCE(I_MAABC) TYPE  MAABC DEFAULT ' '
*"     REFERENCE(I_MAIN) TYPE  XFELD DEFAULT 'X'
*"     REFERENCE(I_AUX) TYPE  XFELD DEFAULT ' '
*"  TABLES
*"      IT_WERKS STRUCTURE  RANGE_WERKS_S
*"      IT_BUKRS STRUCTURE  RANGE_BUKRS_CO
*"      IT_MATNR STRUCTURE  RANGE_MATNR
*"      IT_KLVAR STRUCTURE  ZRANGE_KLVAR
*"      IT_TVERS STRUCTURE  RSTVERS
*"      IT_KADKY STRUCTURE  ZRANGE_KADKY
*"      IT_BONUS STRUCTURE  ZRANGE_BONUS OPTIONAL
*"      IT_MVGR1 STRUCTURE  ZRANGE_MVGR1 OPTIONAL
*"      IT_MVGR2 STRUCTURE  ZRANGE_MVGR1 OPTIONAL
*"      IT_MVGR3 STRUCTURE  ZRANGE_MVGR1 OPTIONAL
*"      IT_MVGR4 STRUCTURE  ZRANGE_MVGR1 OPTIONAL
*"      IT_MVGR5 STRUCTURE  ZRANGE_MVGR1 OPTIONAL
*"      IT_PRCTR STRUCTURE  RANGE_PRCTR OPTIONAL
*"      IT_ARBPL STRUCTURE  RANGE_S_ARBPL OPTIONAL
*"      IT_BKLAS STRUCTURE  FAGL_MM_RANGE_BKLAS OPTIONAL
*"      IT_MATKL STRUCTURE  MATKL_RAN OPTIONAL
*"      ET_OUTPUT STRUCTURE  ZRFI028_ALV
*"----------------------------------------------------------------------
*"      ET_OUTPUT STRUCTURE  ZBW_RFI028_EXTRACT  " <<< CHANGED
*"----------------------------------------------------------------------

* Assume ty_calctab (for i_calctab, gs_calctab) is defined globally
* and includes: vtweg TYPE vtweg, bwkey TYPE bwkey,
* and all fields selected from KEKO, MARC, MARA, MBEW, KEPH, CKIS.

  TYPES: BEGIN OF lty_arbpl,
           plnty type plas-plnty,
           plnnr type plas-plnnr,
           plnal type plas-plnal,
           datuv type plpo-datuv,
           arbpl type crhd-arbpl,
           datub type plpod-datub,
         END OF lty_arbpl.

  TYPES: BEGIN OF lty_mvke,
           matnr type matnr,
           vkorg type vkorg,
           vtweg TYPE vtweg, " <<< ADDED
         END OF lty_mvke.

  data: lr_lvorm                  type standard table of range_c1,
        lr_maabc                  type standard table of range_c1,
        ls_lvorm                  type range_c1,
        ls_maabc                  type range_c1,
        lv_tabix                  like sy-tabix,
        lv_losgr                  like keko-losgr,
        lv_felt(30),        
        lv_elehk                  type ck_elesmhk,
        lt_arbpl                  type standard table of lty_arbpl,
        lt_calctab                type standard table of ty_calctab, " Used for intermediate steps
        lt_mvke                   type hashed table of lty_mvke
                                       with unique key matnr, " Assuming one entry per MATNR for a given I_VKORG
        ls_arbpl                  like line of lt_arbpl.

  DATA: gs_output TYPE zbw_rfi028_extract. " <<< New output structure work area

  field-symbols: <ls_mvke>   type lty_mvke.
  field-symbols: <ls_prev>        like line of lt_arbpl,
                 <ls_arbpl_plnnr> like line of lt_arbpl,
                 <ls_arbpl_plnal> like line of lt_arbpl,
                 <ls_arbpl_datuv> like line of lt_arbpl.
  FIELD-SYMBOLS: <calctab>     TYPE ty_calctab. " For loop at i_calctab
  FIELD-SYMBOLS: <f>           TYPE any.
  FIELD-SYMBOLS: <kpf_dec>     TYPE any. " For GV_KST_DEC<g_decima>
  FIELD-SYMBOLS: <sum_kpf_dec> TYPE any. " For GS_SUMTAB-KPF_DEC<g_decima>
  FIELD-SYMBOLS: <output_kst>  TYPE any. " For GS_OUTPUT-KSTnnn
  FIELD-SYMBOLS: <tckh3>       TYPE tckh3.
  FIELD-SYMBOLS: <tckh2>       TYPE tckh2.
  FIELD-SYMBOLS: <ls_00192>    TYPE ypar_s_values.


*-----------------------------------------------------------------
* Init values
*-----------------------------------------------------------------
  set parameter id 'KRT' field it_klvar-low.

  gv_felt = 'GV_KST_DEC' && g_decima. "CONCATENATE 'GV_KST_DEC' g_decima INTO gv_felt.
  assign (gv_felt) to <kpf_dec>.
  gv_felt = 'GS_SUMTAB-KPF_DEC' && g_decima. "CONCATENATE 'GS_SUMTAB-KPF_DEC' g_decima INTO gv_felt.
  assign (gv_felt) to <sum_kpf_dec>.

  select elehk elehkns into table gi_tck07
    from tck07
   where bukrs in it_bukrs
     and ( klvar in it_klvar or klvar = '++++' ).
  if sy-subrc ne 0.
    select elehk elehkns into table gi_tck07
      from tck07
     where ( bukrs in it_bukrs or bukrs = '++++' )
       and ( klvar in it_klvar or klvar = '++++' ).
    if sy-subrc ne 0.
      select elehk elehkns into table gi_tck07
        from tck07
       where klvar in it_klvar or klvar = '++++'.
    endif.
  endif.
  sort gi_tck07.
  delete adjacent duplicates from gi_tck07.
  describe table gi_tck07 lines gv_lines.
  if gv_lines = 1.
    read table gi_tck07 into gs_tck07 index 1.
    case 'X'.
      when i_main.
        gv_elehk   = gs_tck07-elehk.
        gv_elehkns = gs_tck07-elehkns.
        gv_keart = 'H'.
      when i_aux.
        gv_elehk   = gs_tck07-elehk.
        gv_elehkns = gs_tck07-elehkns.
        gv_keart = 'N'.
    endcase.
  else.
    message e016(zfi).
  endif.

* Read YPAR No. 00192 -Relation: Master Resipe plant planalternativ and search plant in ZFK_UDBYTTE
  ycl_tmn_pm_services=>read_param( exporting i_paramno = 00192
                                   importing e_values_tab = gt_00192 ).

*------------------------------------------------------------------
* Get data
*------------------------------------------------------------------
  case 'X'.
    when i_main.
      lv_elehk = gv_elehk.
    when i_aux.
      lv_elehk = gv_elehkns.
  endcase.
*   Omkostningselementer
  select * from tckh3 into table gi_tckh3
    where elehk = lv_elehk.
  sort gi_tckh3.
*   Allokering: Omkostningsartsinterval - elementskema
  select * from tckh2 into table gi_tckh2
    where ktopl = '0001'
      and elehk = lv_elehk
    order by kstav kstab.
  if i_noslet = 'X'.
    ls_lvorm-sign   = 'I'.
    ls_lvorm-option = 'EQ'.
    ls_lvorm-low    = ' '.
    append ls_lvorm to lr_lvorm.
  endif.

  if not i_maabc is initial.
    ls_maabc-sign   = 'I'.
    ls_maabc-option = 'EQ'.
    ls_maabc-low    = i_maabc.
    append ls_maabc to lr_maabc.
  endif.

  case 'X'.
* Only diff in below SELECT statement is  AND   keko~elehk = gv_elehk / AND   keko~elehkns = gv_elehkns
    when i_main.
      select
             keko~fwaer_kpf keko~werks keko~bwkey " <<< ADDED bwkey
             keko~klvar keko~tvers keko~matnr
             mara~/cwm/xcwmat as kzwsm mara~meins mbew~peinh
             marc~maabc keko~kadky keko~losgr ckis~kstar ckis~wrtfw_kpf
             mara~/cwm/xcwmat keph~kalka keph~kst001 keph~kst002
             keph~kst003 keph~kst004 keph~kst005 keph~kst006 keph~kst007
             keph~kst008 keph~kst009 keph~kst010 keph~kst011 keph~kst012
             keph~kst013 keph~kst014 keph~kst015 keph~kst016 keph~kst017
             keph~kst018 keph~kst019 keph~kst020 keph~kst021 keph~kst022
             keph~kst023 keph~kst024 keph~kst025 keph~kst026 keph~kst027
             keph~kst028 keph~kst029 keph~kst030 keph~kst031 keph~kst032
             keph~kst033 keph~kst034 keph~kst035 keph~kst036 keph~kst037
             keph~kst038 keph~kst039 keph~kst040 mara~ersda
             marc~prctr
             keko~plnty  keko~plnnr keko~aldat
             into corresponding fields of table i_calctab
             from keko
             inner join marc on
               marc~matnr = keko~matnr and
               marc~werks = keko~werks
             inner join mara on
               mara~matnr = keko~matnr
             inner join mbew on
               mbew~matnr = keko~matnr and
               mbew~bwkey = keko~bwkey and
               mbew~bwtar = keko~bwtar
             inner join keph on
               keph~bzobj = keko~bzobj and
               keph~kalnr = keko~kalnr and
               keph~kalka = keko~kalka and
               keph~kadky = keko~kadky and
               keph~tvers = keko~tvers and
               keph~bwvar = keko~bwvar and
               keph~losfx = ' '        and
               keph~kkzst = ' '        and
               keph~kkzmm = ' '        and
               keph~kkzma = ' '
             left outer join ckis on
               ckis~lednr = '00' and
               ckis~bzobj = '0' and
               ckis~kalnr = keko~kalnr and
               ckis~kalka = keko~kalka and
               ckis~kadky = keko~kadky and
               ckis~tvers = keko~tvers and
               ckis~bwvar = keko~bwvar and
               ckis~kkzma = ' '
             where keko~kadky in it_kadky
             and   keko~tvers in it_tvers
             and   keko~matnr in it_matnr
             and   keko~werks in it_werks
             and   keko~klvar in it_klvar
             and   keko~kkzma = ' '
             and   keko~elehk = gv_elehk
             and   marc~lvorm in lr_lvorm
             and   marc~maabc in lr_maabc
             and   marc~prctr in it_prctr
             and   mbew~bklas in it_bklas
             and   mara~matkl in it_matkl
             and   keph~keart eq gv_keart.
    when i_aux.
      select
             keko~fwaer_kpf keko~werks keko~bwkey " <<< ADDED bwkey
             keko~klvar keko~tvers keko~matnr
             mara~/cwm/xcwmat as kzwsm mara~meins mbew~peinh
             marc~maabc keko~kadky keko~losgr ckis~kstar ckis~wrtfw_kpf
             mara~/cwm/xcwmat keph~kalka keph~kst001 keph~kst002
             keph~kst003 keph~kst004 keph~kst005 keph~kst006 keph~kst007
             keph~kst008 keph~kst009 keph~kst010 keph~kst011 keph~kst012
             keph~kst013 keph~kst014 keph~kst015 keph~kst016 keph~kst017
             keph~kst018 keph~kst019 keph~kst020 keph~kst021 keph~kst022
             keph~kst023 keph~kst024 keph~kst025 keph~kst026 keph~kst027
             keph~kst028 keph~kst029 keph~kst030 keph~kst031 keph~kst032
             keph~kst033 keph~kst034 keph~kst035 keph~kst036 keph~kst037
             keph~kst038 keph~kst039 keph~kst040 mara~ersda
             marc~prctr
             keko~plnty  keko~plnnr keko~aldat
             into corresponding fields of table i_calctab
             from keko
             inner join marc on
               marc~matnr = keko~matnr and
               marc~werks = keko~werks
             inner join mara on
               mara~matnr = keko~matnr
             inner join mbew on
               mbew~matnr = keko~matnr and
               mbew~bwkey = keko~bwkey and
               mbew~bwtar = keko~bwtar
             inner join keph on
               keph~bzobj = keko~bzobj and
               keph~kalnr = keko~kalnr and
               keph~kalka = keko~kalka and
               keph~kadky = keko~kadky and
               keph~tvers = keko~tvers and
               keph~bwvar = keko~bwvar and
               keph~losfx = ' '        and
               keph~kkzst = ' '        and
               keph~kkzmm = ' '        and
               keph~kkzma = ' '
             left outer join ckis on
               ckis~lednr = '00' and
               ckis~bzobj = '0' and
               ckis~kalnr = keko~kalnr and
               ckis~kalka = keko~kalka and
               ckis~kadky = keko~kadky and
               ckis~tvers = keko~tvers and
               ckis~bwvar = keko~bwvar and
               ckis~kkzma = ' '
             where keko~kadky in it_kadky
             and   keko~tvers in it_tvers
             and   keko~matnr in it_matnr
             and   keko~werks in it_werks
             and   keko~klvar in it_klvar
             and   keko~kkzma = ' '
*               AND   keko~elehk = gv_elehk
             and   keko~elehkns = gv_elehkns
             and   marc~lvorm in lr_lvorm
             and   marc~maabc in lr_maabc
             and   marc~prctr in it_prctr
             and   mbew~bklas in it_bklas
             and   mara~matkl in it_matkl
             and   keph~keart eq gv_keart.
  endcase.
  sort i_calctab.

  if i_topniv = ' '.
    delete adjacent duplicates from i_calctab comparing fwaer_kpf
                                                        werks
                                                        klvar
                                                        matnr
                                                        kadky.
  endif.

*   Læs arbejdsplads
  if i_calctab[] is not initial.
    lt_calctab[] = i_calctab[].
    delete lt_calctab where plnty is initial
                         or plnnr is initial.    
    if lt_calctab[] is not initial.
      sort lt_calctab by plnty
                        plnnr.
      delete adjacent duplicates from lt_calctab
                            comparing plnty
                                      plnnr.
      select plas~plnty
            plas~plnnr
            plas~plnal
            plpo~datuv
            crhd~arbpl
        into table lt_arbpl
        from plas
        join plpo on plas~plnty = plpo~plnty
                and plas~plnnr = plpo~plnnr
                and plas~plnkn = plpo~plnkn
        join crhd on plpo~arbid = crhd~objid
        for all entries in lt_calctab
        where plas~plnty eq lt_calctab-plnty
        and plas~plnnr eq lt_calctab-plnnr
        and plpo~vornr eq '0100' "Assuming this is relevant
        and crhd~arbpl in it_arbpl
        and plpo~loekz eq space.
      sort lt_arbpl.
*   for at lave det lettere at finde det rigtige workcenter ud fra en dato,
*   laves der et DATUB felt i LT_ARBPL.
      loop at lt_arbpl assigning <ls_arbpl_plnnr> group by <ls_arbpl_plnnr>-plnnr.
        loop at group <ls_arbpl_plnnr> assigning <ls_arbpl_plnal> group by <ls_arbpl_plnal>-plnal.
          loop at group <ls_arbpl_plnal> assigning <ls_arbpl_datuv>.
            if <ls_prev> is assigned.
              <ls_prev>-datub =  <ls_arbpl_datuv>-datuv - 1.
            endif.
            assign <ls_arbpl_datuv> to <ls_prev>.
          endif.
          if sy-subrc eq 0 and <ls_arbpl_datuv> is assigned. "Check if <ls_arbpl_datuv> is assigned
            <ls_arbpl_datuv>-datub = '99991231'. "Update the date on the last record
          endif.
          unassign <ls_prev>.
        endloop.
      endloop.
    endif.
  endif.
*   Læs salgsdata til materiale
  if  i_vkorg is not initial and
      i_calctab[] is not initial.
    data: lt_mvke_temp type standard table of lty_mvke.
    lt_calctab[] = i_calctab[].
    sort lt_calctab by matnr.
    delete adjacent duplicates from lt_calctab
                          comparing matnr.
    select matnr
           vkorg
           vtweg " <<< ADDED
      from mvke
      into table lt_mvke_temp
       for all entries in lt_calctab
     where matnr =  lt_calctab-matnr
       and vkorg =  i_vkorg
*      AND bonus IN it_bonus  " Filters removed as fields not in output
*      AND mvgr1 IN it_mvgr1
*      AND mvgr2 IN it_mvgr2
*      AND mvgr3 IN it_mvgr3
*      AND mvgr4 IN it_mvgr4
*      AND mvgr5 IN it_mvgr5
       .
    if lt_mvke_temp is not initial.
      sort lt_mvke_temp by matnr.
      delete adjacent duplicates from lt_mvke_temp comparing matnr. " Keep one VTWEG per MATNR for this VKORG
      lt_mvke[] = lt_mvke_temp[]. " Populate hashed table
    endif.
  endif.

*   Relevante Omkostningselementer for selektionen
  refresh: et_output.
  loop at i_calctab assigning <calctab>.

    if i_vkorg is not initial.
      read table lt_mvke
         assigning <ls_mvke>
         with table key matnr = <calctab>-matnr.
      if sy-subrc = 0.
        <calctab>-vkorg = <ls_mvke>-vkorg. " Already set if I_VKORG is used for selection
        <calctab>-vtweg = <ls_mvke>-vtweg.
      else.
        " If I_VKORG is set, and no sales data, original code deleted the entry.
        " This is a critical business decision. If material should be excluded:
        delete i_calctab. " Modifies the table being looped over.
        continue.
        " Alternatively, clear sales-specific fields if the material should still be processed:
        " CLEAR: <calctab>-vkorg, <calctab>-vtweg.
      endif.
    endif.

    if <calctab>-plnnr is not initial.
      read table gt_00192 assigning <ls_00192> with key key1 = <calctab>-werks.
      if sy-subrc eq 0.
        clear ls_arbpl. " Ensure ls_arbpl is cleared before loop
        loop at lt_arbpl into ls_arbpl where plnty = <calctab>-plnty
                                         and plnnr = <calctab>-plnnr
                                         and plnal = <ls_00192>-key2
                                         and datuv <= <calctab>-kadky
                                         and datub >=  <calctab>-kadky.
          <calctab>-arbpl = ls_arbpl-arbpl.
          exit. " Found one
        endloop.
        if sy-subrc <> 0. " Not found with kadky, try aldat
          clear ls_arbpl.
          loop at lt_arbpl into ls_arbpl where plnty = <calctab>-plnty
                                           and plnnr = <calctab>-plnnr
                                           and plnal = <ls_00192>-key2
                                           and datuv <= <calctab>-aldat
                                           and datub >=  <calctab>-aldat.
            <calctab>-arbpl = ls_arbpl-arbpl.
            exit. " Found one
          endloop.
        endif.
      endif.
    endif.
  endloop.

  " Main processing loop for AT NEW / AT END logic
  loop at i_calctab into gs_calctab.
    clear: gs_output.
    lv_losgr = gs_calctab-losgr.

    gs_output-fwaer_kpf = gs_calctab-fwaer_kpf.
    gs_output-werks     = gs_calctab-werks.
    gs_output-vkorg     = gs_calctab-vkorg. " Populated if I_VKORG is set & data found
    gs_output-vtweg     = gs_calctab-vtweg. " Populated if I_VKORG is set & data found
    gs_output-klvar     = gs_calctab-klvar.
    gs_output-tvers     = gs_calctab-tvers.
    gs_output-matnr     = gs_calctab-matnr.
    gs_output-kadky     = gs_calctab-kadky.
    gs_output-prctr     = gs_calctab-prctr.
    gs_output-arbpl     = gs_calctab-arbpl.
    gs_output-plnnr     = gs_calctab-plnnr.
    gs_output-topniv    = i_topniv.

    SELECT SINGLE bukrs FROM t001k INTO gs_output-bukrs
      WHERE bwkey = gs_calctab-bwkey. " Assumes Plant (WERKS) is Valuation Area (BWKEY)
    IF sy-subrc <> 0. " Fallback if BWKEY in T001K is not WERKS or not found
      SELECT SINGLE bukrs FROM t001k INTO gs_output-bukrs
        WHERE werks = gs_calctab-werks.
    ENDIF.

    at new kadky.
      refresh gi_sumtab.
      loop at gi_tckh3 assigning <tckh3>.
        if sy-tabix > c_omkelem. " c_omkelem is likely 40, from global constants
          exit.
        endif.
        gs_sumtab-elemt = <tckh3>-elemt.
        clear <sum_kpf_dec>.
        append gs_sumtab to gi_sumtab.
      endloop.
    endat.
    if gs_calctab-kstar is initial or
       i_topniv = ' '.
      loop at gi_tckh3 assigning <tckh3>.
        gs_sumtab-elemt = <tckh3>-elemt.
        concatenate 'GS_CALCTAB-KST' <tckh3>-el_hv into lv_felt.
        assign (lv_felt) to <f>.
        if <f> is assigned.
          move <f> to <sum_kpf_dec>. " Moves value to GS_SUMTAB-KPF_DEC<g_decima>
          if gs_calctab-omrfak <> 0 and gs_calctab-omrfak is not initial. " Avoid division by zero
            <sum_kpf_dec> = ( <sum_kpf_dec> / gs_calctab-omrfak ).
          endif.
          collect gs_sumtab into gi_sumtab.
        endif.
      endloop.
    else.
      " This assignment should point to the correct component in gs_sumtab
      gv_felt = 'GS_SUMTAB-KPF_DEC' && g_decima.
      assign component gv_felt of structure gs_sumtab to <sum_kpf_dec>.
      if <sum_kpf_dec> is assigned.
        loop at gi_tckh2 assigning <tckh2> where kstav <= gs_calctab-kstar
                                             and kstab >= gs_calctab-kstar.
          gs_sumtab-elemt = <tckh2>-elemt.
          <sum_kpf_dec> = gs_calctab-wrtfw_kpf.
          collect gs_sumtab into gi_sumtab.
          exit.
        endloop.
      endif.
    endif.
    at end of kadky.
      clear gs_output-total.
      data: lv_current_comp_value type zcurr13_5, " Matches KST001-020 type
            lv_sum_kpf_dec_val    type p decimals g_decima. " To hold value from gs_sumtab's dynamic field

      loop at gi_sumtab into gs_sumtab.
        " Get the aggregated value from gs_sumtab's dynamic field (e.g., KPF_DEC2)
        gv_felt = 'KPF_DEC' && g_decima. " Component name in gs_sumtab structure
        assign component gv_felt of structure gs_sumtab to <f>.
        if <f> is assigned.
          lv_sum_kpf_dec_val = <f>.
        else.
          clear lv_sum_kpf_dec_val.
        endif.

        if lv_losgr <> 0 and lv_losgr is not initial. " Avoid division by zero
          lv_current_comp_value = lv_sum_kpf_dec_val / lv_losgr.
        else.
          lv_current_comp_value = lv_sum_kpf_dec_val.
        endif.

        if gs_sumtab-elemt <= '020'. " Output KST001 to KST020
          concatenate 'KST' gs_sumtab-elemt into lv_felt. " Component name in gs_output (e.g., KST001)
          assign component lv_felt of structure gs_output to <output_kst>.
          if sy-subrc = 0. " Check if field KSTnnn exists in gs_output
            <output_kst> = lv_current_comp_value.
          endif.
        endif.
        add lv_current_comp_value to gs_output-total. " Sum all components for TOTAL
      endloop.
      append gs_output to et_output.
    endat.

  endloop.

  sort et_output.

endfunction.