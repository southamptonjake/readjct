/* REXX */

x1 = get_stepname()
return 0

/***********************************************************************
* GET_STEPNAME:                                                        *
*                                                                      *
* This procedure finds the stepname to cater for special processing    *
***********************************************************************/
get_stepname:
  tcb  = ptr(540, 4)                              /* PSATOLD  in PSA  */
  tiot = ptr(tcb + 12, 4)                         /* TCBTIO   in TCB  */
  jscb = ptr(tcb + 180, 4)                        /* TCBJSCB  in TCB  */
  jct  = swareq(stg(jscb + 260, 4))               /* JSCBJCTA in JSCB */
  act  = ptr(jct + 40, 3)                         /* JCTACTAD in JCT  */
  ssib = ptr(jscb + 316, 4)                       /* JSCBSSIB in JSCB */

  programmer   = stg(act + 24, 20)
  actaccnt     = stg(act + 49, 128)
  jobid        = stg(ssib + 12, 8)
  jobidnc      = strip(substr(stg(ssib + 12, 8), 4, 5))
  msgclass     = stg(jct + 6, 1)
  jobname      = stg(tiot, 8)
  stepname     = stg(tiot + 8, 8)
  procstepname = stg(tiot + 16, 8)

  say 'tcb  ADDR      :' d2x(tcb)
  say 'tiot ADDR      :' d2x(tiot)
  say 'jscb ADDR      :' d2x(jscb)
  say 'JCT ADDR       :' d2x(jct)
  say 'prog_ADDR      :' d2x(act + 24)
  say 'acct_ADDR      :' d2x(act + 49)
  say 'acct_ALLIGN    :' d2x(act + 52)


  say 'Job Name       :' jobname
  say 'Programmer name:' programmer
  say 'actaccnt:      :' actaccnt
  say 'actaccnt hex:  :' c2x(actaccnt)
  say 'Proc step name :' procstepname
  say 'Step name      :' stepname
  say 'Message class  :' msgclass
  say 'Job number     :' jobid
return 0

/***********************************************************************
* PTR & STG & SWAREQ:                                                  *
*                                                                      *
* Utility procedures to access z/OS control blocks                     *
***********************************************************************/
ptr: return c2d(storage(d2x(arg(1)), arg(2)))
stg: return storage(d2x(arg(1)), arg(2))

swareq: procedure
  if right(c2x(arg(1)), 1) \= 'F' then  /* SWA=BELOW ?                */
    return c2d(arg(1)) + 16             /* Yes, return SVA + 16       */

  sva  = c2d(arg(1))                    /* Convert to decimal         */
  tcb  = ptr(540, 4)                    /* TCB PSATOLD                */
  jscb = ptr(tcb + 180, 4)              /* JSCB TCBJSCB               */
  qmpl = ptr(jscb + 244, 4)             /* QMPL JSCBQMPI              */
  qmat = ptr(qmpl + 24, 4)              /* QMAT QMADD                 */
  do while sva > 65536
    qmat = ptr(qmat + 12, 4)            /* Next QMAT QMAT + 12        */
    sva  = sva - 65536                  /* 010006F -> 000006F         */
  end

return ptr(qmat + sva + 1) + 16
