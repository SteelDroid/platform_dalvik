%verify "executed"
    /*
     * Long integer shift.  This is different from the generic 32/64-bit
     * binary operations because vAA/vBB are 64-bit but vCC (the shift
     * distance) is 32-bit.  Also, Dalvik requires us to mask off the low
     * 6 bits of the shift distance.  x86 shifts automatically mask off
     * the low 5 bits of %cl, so have to handle the 64 > shiftcount > 31
     * case specially.
     */
    /* shr-long vAA, vBB, vCC */
    /* ecx gets shift count */
    /* Need to spill edx */
    /* rINST gets AA */
    movzbl    2(rPC),%eax               # eax<- BB
    movzbl    3(rPC),%ecx               # ecx<- CC
    SPILL(rPC)                          # spill edx
    GET_VREG_WORD(%edx,%eax,1)          # edx<- v[BB+1]
    GET_VREG  (%ecx,%ecx)               # ecx<- vCC
    GET_VREG_WORD(%eax,%eax,0)          # eax<- v[BB+0]
    shrdl     %edx,%eax
    shrl      %cl,%edx
    testb     $$32,%cl
    je        2f
    movl      %edx,%eax
    xorl      %edx,%edx
2:
    movzbl    rINST_HI,%ecx
    SET_VREG_WORD(%edx,%ecx,1)         # v[BB+1]<- edx
    UNSPILL(rPC)
    jmp       .L${opcode}_finish
%break


.L${opcode}_finish:
    SET_VREG_WORD(%eax,%ecx,0)        # v[BB+0]<- eax
    FETCH_INST_WORD(2)
    ADVANCE_PC(2)
    GOTO_NEXT
