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
*"      ET_TCKH1 STRUCTURE  TCKH1 OPTIONAL
*"----------------------------------------------------------------------

  types: begin of lty_hlp_calctab,
           matnr type objnum,
         end of lty_hlp_calctab,
         begin of lty_cawnt,
           atinn type atinn,
           atzhl type atzhl,
           atwtb type atwtb,
         end of lty_cawnt,
         begin of lty_ausp,
           objek type objnum,
           atinn type atinn,
           atwrt type atwrt,
           atwtb type atwtb,
         end of lty_ausp,
         begin of lty_mvgr,
           mvgr  type mvgr1,
           bezei type bezei40,
         end of lty_mvgr,
         lt_mvgr type standard table of lty_mvgr,
         begin of lty_tvbo,
           bonus type tvbot-bonus,
           vtext type char20,
         end of lty_tvbo,
         begin of lty_arbpl,
           plnty type plas-plnty,
           plnnr type plas-plnnr,
           plnal type plas-plnal,
           datuv type plpo-datuv,
           arbpl type crhd-arbpl,
           datub type plpod-datub,
         end of lty_arbpl,
         begin of lty_mvke,
           matnr type matnr,
           vkorg type vkorg,
           mvgr1 type mvgr1,
           mvgr2 type mvgr2,
           mvgr3 type mvgr3,
           mvgr4 type mvgr4,
           mvgr5 type mvgr5,
           bonus type bonus,
           ktgrm type ktgrm,
         end of lty_mvke.

  data: lr_lvorm                  type standard table of range_c1,
        lr_maabc                  type standard table of range_c1,
        ls_lvorm                  type range_c1,
        ls_maabc                  type range_c1,
        lv_tabix                  like sy-tabix,
        lv_losgr                  like keko-losgr,
        lv_felt(30),
        lv_dc_segment             type atinn,
        lv_dc_season              type atinn,
        lv_dc_prisstr             type atinn,
        lv_dc_noglehul            type atinn,
        lv_dc_varegruppe          type atinn,
        lv_dc_naeringsdeklaration type atinn,
        lt_kendetegn              type standard table of lty_ausp,
        ls_kendetegn              type lty_ausp,
        lt_hlp_calctab            type standard table of lty_hlp_calctab,
        ls_hlp_calctab            type lty_hlp_calctab,
        lt_cawnt                  type standard table of lty_cawnt,
        ls_cawnt                  type lty_cawnt,
        lt_marm                   type standard table of marm,
        ls_marm                   type marm,
        lt_tvkm                   type standard table of tvkmt,
        ls_tvkm                   type tvkmt,
        lt_tvbo                   type standard table of lty_tvbo,
        ls_tvbo                   type lty_tvbo,
        lv_objek                  type objnr,
        lv_mvgr                   type mvgr1,
        lt_mvgr1                  type standard table of lty_mvgr,
        lt_mvgr2                  type standard table of lty_mvgr,
        lt_mvgr3                  type standard table of lty_mvgr,
        lt_mvgr4                  type standard table of lty_mvgr,
        lt_mvgr5                  type standard table of lty_mvgr,
        lv_mvgr_name              type char10 value 'lt_mvgr1',
        lv_tvm                    type char5 value 'tvm1t',
        lv_mvgr1_bezei            type char11 value 'mvgr1 bezei',
        lv_mvgr_key               type char25 value 'mvgr1 = <mvgr_tab>-mvgr',
        lv_bezei                  type char20 value 'GS_OUTPUT-BEZEI1',
        l_atzhl                   type atzhl,
        lv_elehk                  type ck_elesmhk,
        lt_arbpl                  type standard table of lty_arbpl,
        lt_calctab                type standard table of ty_calctab,
        lt_mvke                   type hashed table of lty_mvke
                                       with unique key matnr,
        ls_arbpl                  like line of lt_arbpl.

  field-symbols: <kendetegn> type lty_ausp,
                 <mvgr>      type lty_mvgr,
                 <mvgr_tab>  type lt_mvgr,
                 <mvgr_key>  type mvgr1,
                 <bezei>     type bezei20,
                 <ls_mvke>   type lty_mvke.
  field-symbols: <ls_prev>        like line of lt_arbpl,
                 <ls_arbpl_plnnr> like line of lt_arbpl,
                 <ls_arbpl_plnal> like line of lt_arbpl,
                 <ls_arbpl_datuv> like line of lt_arbpl.

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
*   Omkostningselementer - tekster
  select * from tckh1 into table gi_tckh1 up to c_omkelem rows
    where spras = sy-langu
    and elehk = lv_elehk.
*    sort gi_tckh1 by elemt. "HANA issue
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
             keko~fwaer_kpf keko~werks
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
             keko~fwaer_kpf keko~werks
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
       and plpo~vornr eq '0100'
       and crhd~arbpl in it_arbpl
       and plpo~loekz eq space.
    sort lt_arbpl.
* for at lave det lettere at finde det rigtige workcenter ud fra en dato,
* laves der et DATUB felt i LT_ARBPL.
    loop at lt_arbpl assigning <ls_arbpl_plnnr> group by <ls_arbpl_plnnr>-plnnr.
      loop at group <ls_arbpl_plnnr> assigning <ls_arbpl_plnal> group by <ls_arbpl_plnal>-plnal.
        loop at group <ls_arbpl_plnal> assigning <ls_arbpl_datuv>.
          if <ls_prev> is assigned.
            <ls_prev>-datub =  <ls_arbpl_datuv>-datuv - 1.
          endif.
          assign <ls_arbpl_datuv> to <ls_prev>.
        endloop.
        if sy-subrc eq 0.
          <ls_arbpl_datuv>-datub = '99991231'. "Update the date on the last record
        endif.
        unassign <ls_prev>.
      endloop.
    endloop.

  endif.
*   Læs salgsdata til materiale
  if  i_vkorg is not initial and
      i_calctab[] is not initial.

    lt_calctab[] = i_calctab[].
    sort lt_calctab by matnr.
    delete adjacent duplicates from lt_calctab
                          comparing matnr.

    select matnr
           vkorg
           mvgr1
           mvgr2
           mvgr3
           mvgr4
           mvgr5
           bonus
           ktgrm
      from mvke
      into table lt_mvke
       for all entries in lt_calctab
     where matnr =  lt_calctab-matnr
       and vkorg =  i_vkorg
       and bonus in it_bonus
       and mvgr1 in it_mvgr1
       and mvgr2 in it_mvgr2
       and mvgr3 in it_mvgr3
       and mvgr4 in it_mvgr4
       and mvgr5 in it_mvgr5.

  endif.

*   Relevante Omkostningselementer for selektionen
  refresh: et_output.
  loop at i_calctab assigning <calctab>.

    if i_vkorg is not initial.

      read table lt_mvke
         assigning <ls_mvke>
         with table key matnr = <calctab>-matnr.

      if sy-subrc = 0.
        move-corresponding <ls_mvke> to <calctab>.
      else.
        delete i_calctab.
        continue.
      endif.

    endif.

    if <calctab>-plnnr is not initial.
      read table gt_00192 assigning <ls_00192> with key key1 = <calctab>-werks.
      if sy-subrc eq 0.
        loop at lt_arbpl into ls_arbpl where plnty = <calctab>-plnty
                                         and plnnr = <calctab>-plnnr
                                         and plnal = <ls_00192>-key2
                                         and datuv <= <calctab>-kadky
                                         and datub >=  <calctab>-kadky.

        endloop.
        if sy-subrc eq 0.
          <calctab>-arbpl = ls_arbpl-arbpl.
        else.
          loop at lt_arbpl into ls_arbpl where plnty = <calctab>-plnty
                                           and plnnr = <calctab>-plnnr
                                           and plnal = <ls_00192>-key2
                                           and datuv <= <calctab>-aldat
                                           and datub >=  <calctab>-aldat.

          endloop.
          if sy-subrc eq 0.
            <calctab>-arbpl = ls_arbpl-arbpl.
          endif.
        endif.
      endif.
    endif.

    move-corresponding <calctab> to ls_hlp_calctab.
    append ls_hlp_calctab to lt_hlp_calctab.
    do 5 times varying lv_mvgr from <calctab>-mvgr1 next <calctab>-mvgr2.
      check not lv_mvgr is initial.
      lv_mvgr_name+7(1) = sy-index.
      assign (lv_mvgr_name) to <mvgr_tab>.
      append initial line to <mvgr_tab> assigning <mvgr>.
      <mvgr>-mvgr = lv_mvgr.
    enddo.
    if not <calctab>-bonus is initial.
      ls_tvbo-bonus = <calctab>-bonus.
      append ls_tvbo to lt_tvbo.
    endif.
  endloop.
  sort lt_tvbo.
  delete adjacent duplicates from lt_tvbo.
  sort lt_hlp_calctab.
  delete adjacent duplicates from lt_hlp_calctab.
  do 5 times.
    lv_tvm+3(1) = sy-index.
    lv_mvgr1_bezei+4(1) = sy-index.
    lv_mvgr_name+7(1) = sy-index.
    lv_mvgr_key+4(1) = sy-index.
    assign (lv_mvgr_name) to <mvgr_tab>.
    check not <mvgr_tab> is initial.
    sort <mvgr_tab>.
    delete adjacent duplicates from <mvgr_tab>.
    select (lv_mvgr1_bezei) into table <mvgr_tab>
        from (lv_tvm)
        for all entries in <mvgr_tab>
        where (lv_mvgr_key)
        and   spras = sy-langu.
  enddo.

  select single atinn into lv_dc_season
      from cabn
      where atnam = 'DC_SEASON'.
  select single atinn into lv_dc_segment
      from cabn
      where atnam = 'DC_SEGMENT'.
  select single atinn into lv_dc_prisstr
      from cabn
      where atnam = 'DC_PRISSTRATEGI'.
  select single atinn into lv_dc_noglehul
      from cabn
      where atnam = 'DC_NOGLEHUL'.
  select single atinn into lv_dc_varegruppe
      from cabn
      where atnam = 'DC_VAREGRUPPE'.
  select single atinn into lv_dc_naeringsdeklaration
      from cabn
      where atnam = 'DC_NAERINGSDEKLARATION'.
  select atinn atzhl atwtb into corresponding fields of table lt_cawnt
      from cawnt
      where spras = sy-langu
      and ( atinn = lv_dc_segment
      or    atinn = lv_dc_season
      or    atinn = lv_dc_prisstr
      or    atinn = lv_dc_noglehul
      or    atinn = lv_dc_varegruppe
      or    atinn = lv_dc_naeringsdeklaration ).
  if not lt_hlp_calctab[] is initial.
    select objek atinn atwrt into corresponding fields of table lt_kendetegn
        from ausp
        for all entries in lt_hlp_calctab
        where objek = lt_hlp_calctab-matnr
        and ( atinn = lv_dc_segment
        or    atinn = lv_dc_season
        or    atinn = lv_dc_prisstr
        or    atinn = lv_dc_noglehul
        or    atinn = lv_dc_varegruppe
        or    atinn = lv_dc_naeringsdeklaration ).
    sort lt_kendetegn by objek atinn.
    loop at lt_kendetegn assigning <kendetegn>.
      select single atzhl from cawn into l_atzhl where atinn = <kendetegn>-atinn
                                                   and atwrt = <kendetegn>-atwrt.
      if sy-subrc = 0.
        read table lt_cawnt into ls_cawnt with key atinn = <kendetegn>-atinn
                                                    atzhl = l_atzhl.
        if sy-subrc = 0.
          <kendetegn>-atwtb = ls_cawnt-atwtb.
        endif.
      endif.
    endloop.

    select * into corresponding fields of table lt_marm
      from marm
      for all entries in  i_calctab
      where matnr = i_calctab-matnr.

    select * into corresponding fields of table lt_tvkm
        from tvkmt
      for all entries in  i_calctab
        where ktgrm = i_calctab-ktgrm
        and   spras = sy-langu.
  endif.

  if not lt_tvbo[] is initial.
    select * into corresponding fields of table lt_tvbo
        from tvbot
        for all entries in lt_tvbo
        where bonus = lt_tvbo-bonus
        and   spras = sy-langu.
  endif.

  loop at i_calctab into gs_calctab.
    clear: gs_output.
    lv_losgr = gs_calctab-losgr.
    gs_output-vkorg     = gs_calctab-vkorg.
    gs_output-cwmat     = gs_calctab-/cwm/xcwmat.
    gs_output-maabc     = gs_calctab-maabc.
    gs_output-bonus     = gs_calctab-bonus.
    gs_output-mvgr1     = gs_calctab-mvgr1.
    gs_output-mvgr2     = gs_calctab-mvgr2.
    gs_output-mvgr3     = gs_calctab-mvgr3.
    gs_output-mvgr4     = gs_calctab-mvgr4.
    gs_output-mvgr5     = gs_calctab-mvgr5.
    gs_output-aendr     = gs_calctab-ersda.
    gs_output-prctr     = gs_calctab-prctr.
    gs_output-arbpl     = gs_calctab-arbpl.
    gs_output-plnnr     = gs_calctab-plnnr.
    write gs_calctab-ersda to gs_output-aendr dd/mm/yyyy.
    lv_objek = gs_calctab-matnr.
    read table lt_kendetegn assigning <kendetegn> with key objek = lv_objek
                                                           atinn = lv_dc_season
                                                           binary search.
    if sy-subrc = 0.
      gs_output-season = <kendetegn>-atwtb.
    endif.
    read table lt_kendetegn assigning <kendetegn> with key objek = lv_objek
                                                           atinn = lv_dc_segment
                                                           binary search.
    if sy-subrc = 0.
      gs_output-segment = <kendetegn>-atwtb.
    endif.
    read table lt_kendetegn assigning <kendetegn> with key objek = lv_objek
                                                           atinn = lv_dc_prisstr
                                                           binary search.
    if sy-subrc = 0.
      gs_output-prisstrategi = <kendetegn>-atwtb.
    endif.

    read table lt_kendetegn assigning <kendetegn> with key objek = lv_objek
                                                           atinn = lv_dc_noglehul
                                                           binary search.
    if sy-subrc = 0.
      gs_output-noglehul = <kendetegn>-atwtb.
    endif.
    read table lt_kendetegn assigning <kendetegn> with key objek = lv_objek
                                                           atinn = lv_dc_varegruppe
                                                           binary search.
    if sy-subrc = 0.
      gs_output-varegruppe = <kendetegn>-atwtb.
    endif.
    read table lt_kendetegn assigning <kendetegn> with key objek = lv_objek
                                                           atinn = lv_dc_naeringsdeklaration
                                                           binary search.
    if sy-subrc = 0.
      gs_output-naeringsdeklaration = <kendetegn>-atwtb.
    endif.

    read table lt_tvbo into ls_tvbo with key bonus = gs_calctab-bonus.
    if sy-subrc = 0.
      gs_output-bonust = ls_tvbo-vtext.
    endif.

    gs_output-ktgrm = gs_calctab-ktgrm.
    read table lt_tvkm into ls_tvkm with key ktgrm = gs_calctab-ktgrm.
    if sy-subrc = 0.
      gs_output-ktgrmt = ls_tvkm-vtext.
    endif.

    lv_mvgr_key = 'gs_calctab-mvgr1'.
    do 5 times.
      lv_mvgr_key+15(1) = sy-index.
      lv_mvgr_name+7(1) = sy-index.
      lv_bezei+15(1) = sy-index.
      assign (lv_mvgr_name) to <mvgr_tab>.
      assign (lv_mvgr_key) to <mvgr_key>.
      assign (lv_bezei) to <bezei>.
      read table <mvgr_tab> assigning <mvgr> with key mvgr = <mvgr_key>.
      if sy-subrc = 0.
        <bezei> = <mvgr>-bezei.
      else.
        clear: <bezei>.
      endif.
    enddo.
    clear: gs_output-stk_kar, gs_output-vgt_stk, gs_output-vgt_kar.
    read table lt_marm into ls_marm with key matnr = gs_calctab-matnr
                                             meinh = 'ST'.
    if sy-subrc = 0 and
        ls_marm-umren ne 0 and
        ls_marm-umrez ne 0.
      if gs_calctab-/cwm/xcwmat is initial.
        gs_output-vgt_stk = ls_marm-umrez / ls_marm-umren.
      else.
        gs_output-stk_kar = ls_marm-umren / ls_marm-umrez.
      endif.
    endif.
    if gs_calctab-/cwm/xcwmat is initial.
      read table lt_marm into ls_marm with key matnr = gs_calctab-matnr
                                               meinh = 'KAR'.
      if sy-subrc = 0 and
          ls_marm-umren ne 0.
        gs_output-vgt_kar = ls_marm-umrez / ls_marm-umren.
      endif.
      if gs_output-vgt_stk ne 0 and
          gs_output-vgt_kar ne 0.
        gs_output-stk_kar = gs_output-vgt_kar / gs_output-vgt_stk.
      endif.
    else.
      read table lt_marm into ls_marm with key matnr = gs_calctab-matnr
                                               meinh = 'KG'.
      if sy-subrc = 0 and
          ls_marm-umren ne 0.
        gs_output-vgt_kar = ls_marm-umren / ls_marm-umrez.
        if gs_output-stk_kar ne 0.
          gs_output-vgt_stk = gs_output-vgt_kar / gs_output-stk_kar.
        endif.
      endif.
    endif.

    at new kadky.
      refresh gi_sumtab.
      loop at gi_tckh3 assigning <tckh3>.
        if sy-tabix > c_omkelem.
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
        move <f> to <sum_kpf_dec>.
        if gs_calctab-omrfak <> 0.
          <sum_kpf_dec> = ( <sum_kpf_dec> / gs_calctab-omrfak ).
        endif.
        collect gs_sumtab into gi_sumtab.
      endloop.
    else.
      lv_felt = 'GS_SUMTAB-KPF_DEC' && g_decima. "CONCATENATE 'GS_SUMTAB-KPF_DEC' g_decima INTO lv_felt.
      assign (lv_felt) to <sum_kpf_dec>.
      loop at gi_tckh2 assigning <tckh2> where kstav <= gs_calctab-kstar
                                           and kstab >= gs_calctab-kstar.
        gs_sumtab-elemt = <tckh2>-elemt.
        <sum_kpf_dec> = gs_calctab-wrtfw_kpf.
        collect gs_sumtab into gi_sumtab.
        exit.
      endloop.
    endif.
    at end of kadky.
*     Materialetekster
      read table gi_makt into gs_makt
       with key matnr = gs_calctab-matnr binary search.
      if sy-subrc ne 0.
        lv_tabix = sy-tabix.
        select single maktx from makt into gs_makt-maktx
          where matnr = gs_calctab-matnr
            and spras = sy-langu.
        if sy-subrc ne 0.
          select single maktx from makt into gs_makt-maktx
            where matnr = gs_calctab-matnr.
          if sy-subrc ne 0.
            gs_makt-maktx = '???'.
          endif.
        endif.
        gs_makt-matnr = gs_calctab-matnr.
        insert gs_makt into gi_makt index lv_tabix.
      endif.
*     Fyld skærmrække
      gs_output-matnr     = gs_calctab-matnr.
      gs_output-matxt     = gs_makt-maktx.
      gs_output-kadky     = gs_calctab-kadky.
      gs_output-fwaer_kpf = gs_calctab-fwaer_kpf.
      gs_output-werks     = gs_calctab-werks.
      gs_output-klvar     = gs_calctab-klvar.
      gs_output-tvers     = gs_calctab-tvers.
      clear gs_output-total.
      loop at gi_sumtab into gs_sumtab to c_omkelem.
        concatenate 'GS_OUTPUT-KST' gs_sumtab-elemt into lv_felt.
        assign (lv_felt) to <output_kst>.
        if lv_losgr <> 0.
          <kpf_dec> = <sum_kpf_dec> / lv_losgr.
          <sum_kpf_dec> = <kpf_dec>.
        endif.
        <output_kst> = <sum_kpf_dec>.
        add <output_kst> to gs_output-total.
      endloop.
      append gs_output to et_output.
    endat.

  endloop.

  et_tckh1[] = gi_tckh1[].

  sort et_output.

endfunction.