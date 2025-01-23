
 processor 6502
	org $801
StartBlock801:
	; Starting new memory block at $801
	.byte $b ; lo byte of next line
	.byte $8 ; hi byte of next line
	.byte $0a, $00 ; line 10 (lo, hi)
	.byte $9e, $20 ; SYS token and a space
	.byte   $32,$30,$36,$34
	.byte $00, $00, $00 ; end of program
	; Ending memory block at $801
EndBlock801:
	org $810
StartBlock810:
	; Starting new memory block at $810
C64Project
	jmp block1
sprite_x	dc.w	$64
sprite_y	dc.b	$64
map_player_direction	dc.b	$00
	; NodeProcedureDecl -1
	; ***********  Defining procedure : init16x8div
	;    Procedure type : Built-in function
	;    Requires initialization : no
initdiv16x8_divisor = $4C     ;$59 used for hi-byte
initdiv16x8_dividend = $4E	  ;$fc used for hi-byte
initdiv16x8_remainder = $50	  ;$fe used for hi-byte
initdiv16x8_result = $4E ;save memory by reusing divident to store the result
divide16x8
	lda #0	        ;preset remainder to 0
	sta initdiv16x8_remainder
	sta initdiv16x8_remainder+1
	ldx #16	        ;repeat for each bit: ...
divloop16:	asl initdiv16x8_dividend	;dividend lb & hb*2, msb -> Carry
	rol initdiv16x8_dividend+1
	rol initdiv16x8_remainder	;remainder lb & hb * 2 + msb from carry
	rol initdiv16x8_remainder+1
	lda initdiv16x8_remainder
	sec
	sbc initdiv16x8_divisor	;substract divisor to see if it fits in
	tay	        ;lb result -> Y, for we may need it later
	lda initdiv16x8_remainder+1
	sbc initdiv16x8_divisor+1
	bcc skip16	;if carry=0 then divisor didn't fit in yet
	sta initdiv16x8_remainder+1	;else save substraction result as new remainder,
	sty initdiv16x8_remainder
	inc initdiv16x8_result	;and INCrement result cause divisor fit in 1 times
skip16
	dex
	bne divloop16
	rts
end_procedure_init16x8div
	; NodeProcedureDecl -1
	; ***********  Defining procedure : init8x8div
	;    Procedure type : Built-in function
	;    Requires initialization : no
div8x8_c = $4C
div8x8_d = $4E
div8x8_e = $50
	; Normal 8x8 bin div
div8x8_procedure
	lda #$00
	ldx #$07
	clc
div8x8_loop1
	rol div8x8_d
	rol
	cmp div8x8_c
	bcc div8x8_loop2
	sbc div8x8_c
div8x8_loop2
	dex
	bpl div8x8_loop1
	rol div8x8_d
	lda div8x8_d
div8x8_def_end
	rts
end_procedure_init8x8div
	; NodeProcedureDecl -1
	; ***********  Defining procedure : initjoystick
	;    Procedure type : Built-in function
	;    Requires initialization : no
joystickup: .byte 0
joystickdown: .byte 0
joystickleft: .byte 0
joystickright: .byte 0
joystickbutton: .byte 0
callJoystick
	lda #0
	sta joystickup
	sta joystickdown
	sta joystickleft
	sta joystickright
	sta joystickbutton
	lda #%00000001 ; mask joystick up mment
	bit $50      ; bitwise AND with address 56320
	bne joystick_down       ; zero flag is not set -> skip to down
	lda #1
	sta joystickup
joystick_down
	lda #%00000010 ; mask joystick down movement
	bit $50      ; bitwise AND with address 56320
	bne joystick_left       ; zero flag is not set -> skip to down
	lda #1
	sta joystickdown
joystick_left
	lda #%00000100 ; mask joystick left movement
	bit $50      ; bitwise AND with address 56320
	bne joystick_right       ; zero flag is not set -> skip to down
	lda #1
	sta joystickleft
joystick_right
	lda #%00001000 ; mask joystick up movement
	bit $50      ; bitwise AND with address 56320
	bne joystick_button       ; zero flag is not set -> skip to down
	lda #1
	sta joystickright
joystick_button
	lda #%00010000 ; mask joystick up movement
	bit $50      ; bitwise AND with address 56320
	bne callJoystick_end       ; zero flag is not set -> skip to down
	lda #1
	sta joystickbutton
callJoystick_end
	rts
	rts
end_procedure_initjoystick
	; NodeProcedureDecl -1
	; ***********  Defining procedure : InitSprites
	;    Procedure type : User-defined procedure
InitSprites
	; Set sprite location
	ldx #$0 ; optimized, look out for bugs
	lda #$c8
	sta $07f8 + $0,x
	; Setting sprite position
	; isi-pisi: value is constant
	ldy sprite_x+1 ;keep
	lda sprite_x
	ldx #0
	sta $D000,x
	cpy #0
	beq InitSprites_spritepos3
	lda $D010
	ora #%1
	sta $D010
	jmp InitSprites_spriteposcontinue4
InitSprites_spritepos3
	lda $D010
	and #%11111110
	sta $D010
InitSprites_spriteposcontinue4
	inx
	txa
	tay
	lda sprite_y
	sta $D000,y
	; Assigning memory location
	lda #$1
	; Calling storevariable on generic assign expression
	sta $d015
	
; //ändra detta binära tal så att endast sprite nummer 1 sätts på
	; Assigning memory location
	lda #$ff
	; Calling storevariable on generic assign expression
	sta $d01c
	
; // Alla sprites är multicolor
	; Assigning memory location
	lda #$9
	; Calling storevariable on generic assign expression
	sta $d025
	
; //ändra denna så att färgen stämmer överens med din sprite 
	; Assigning memory location
	lda #$1
	; Calling storevariable on generic assign expression
	sta $d026
	lda #$5
	; Calling storevariable on generic assign expression
	sta $D027+$0
	rts
end_procedure_InitSprites
	; NodeProcedureDecl -1
	; ***********  Defining procedure : InitScreen
	;    Procedure type : User-defined procedure
InitScreen
	
; //testa ändra bakgrundsfärgen och ändra key_space till en annan tangent
	; Assigning memory location
	lda #$0
	; Calling storevariable on generic assign expression
	sta $d021
	; Assigning memory location
	lda #$4
	; Calling storevariable on generic assign expression
	sta $d020
	; Clear screen with offset
	lda #$20
	ldx #$fa
InitScreen_clearloop6
	dex
	sta $0000+$400,x
	sta $00fa+$400,x
	sta $01f4+$400,x
	sta $02ee+$400,x
	bne InitScreen_clearloop6
	rts
end_procedure_InitScreen
	
; // Fill screen (at $0400) with blank spaces ($20)
	; NodeProcedureDecl -1
	; ***********  Defining procedure : UpdateSprite
	;    Procedure type : User-defined procedure
UpdateSprite
	lda #%11111111  ; CIA#1 port A = outputs 
	sta $dc03             
	lda #%00000000  ; CIA#1 port B = inputs
	sta $dc02             
	lda $dc00
	sta $50
	jsr callJoystick
	
; //enable jotsyick 2
; // Calculate map_direction
	lda #$0
	; Calling storevariable on generic assign expression
	sta map_player_direction
	; Binary clause Simplified: EQUALS
	lda joystickleft
	; Compare with pure num / var optimization
	cmp #$1;keep
	bne UpdateSprite_edblock11
UpdateSprite_ctb9: ;Main true block ;keep 
	; Test Inc dec D
	dec map_player_direction
UpdateSprite_edblock11
	; Binary clause Simplified: EQUALS
	lda joystickright
	; Compare with pure num / var optimization
	cmp #$1;keep
	bne UpdateSprite_edblock17
UpdateSprite_ctb15: ;Main true block ;keep 
	; Test Inc dec D
	inc map_player_direction
UpdateSprite_edblock17
	; Binary clause Simplified: EQUALS
	lda joystickdown
	; Compare with pure num / var optimization
	cmp #$1;keep
	bne UpdateSprite_edblock23
UpdateSprite_ctb21: ;Main true block ;keep 
	; Optimizer: a = a +/- b
	; Load16bitvariable : map_player_direction
	lda map_player_direction
	clc
	adc #$28
	sta map_player_direction
UpdateSprite_edblock23
	; Binary clause Simplified: EQUALS
	lda joystickup
	; Compare with pure num / var optimization
	cmp #$1;keep
	bne UpdateSprite_edblock29
UpdateSprite_ctb27: ;Main true block ;keep 
	; Optimizer: a = a +/- b
	; Load16bitvariable : map_player_direction
	lda map_player_direction
	sec
	sbc #$28
	sta map_player_direction
UpdateSprite_edblock29
	; Generic 16 bit op
	ldy #0
	lda joystickleft
UpdateSprite_rightvarInteger_var34 = $54
	sta UpdateSprite_rightvarInteger_var34
	sty UpdateSprite_rightvarInteger_var34+1
	; HandleVarBinopB16bit
	; RHS is pure, optimization
	ldy sprite_x+1 ;keep
	lda sprite_x
	clc
	adc joystickright
	; Testing for byte:  #0
	; RHS is byte, optimization
	bcc UpdateSprite_skip36
	iny
UpdateSprite_skip36
	; Low bit binop:
	sec
	sbc UpdateSprite_rightvarInteger_var34
UpdateSprite_wordAdd32
	sta UpdateSprite_rightvarInteger_var34
	; High-bit binop
	tya
	sbc UpdateSprite_rightvarInteger_var34+1
	tay
	lda UpdateSprite_rightvarInteger_var34
	; Calling storevariable on generic assign expression
	sta sprite_x
	sty sprite_x+1
	; 8 bit binop
	; Add/sub where right value is constant number
	; 8 bit binop
	; Add/sub where right value is constant number
	lda sprite_y
	clc
	adc joystickdown
	 ; end add / sub var with constant
	sec
	sbc joystickup
	 ; end add / sub var with constant
	; Calling storevariable on generic assign expression
	sta sprite_y
	; Setting sprite position
	; isi-pisi: value is constant
	ldy sprite_x+1 ;keep
	lda sprite_x
	ldx #0
	sta $D000,x
	cpy #0
	beq UpdateSprite_spritepos37
	lda $D010
	ora #%1
	sta $D010
	jmp UpdateSprite_spriteposcontinue38
UpdateSprite_spritepos37
	lda $D010
	and #%11111110
	sta $D010
UpdateSprite_spriteposcontinue38
	inx
	txa
	tay
	lda sprite_y
	sta $D000,y
	rts
end_procedure_UpdateSprite
block1
main_block_begin_
	jsr InitScreen
	jsr InitSprites
	jsr UpdateSprite
	jmp * ; loop like (�/%
main_block_end_
	; End of program
	; Ending memory block at $810
EndBlock810:
	org $3200
StartBlock3200:
	org $3200
snake:
	incbin	 "C:/Users/maja/Documents/GitHub/Workshop_Trse/workshop///sprites/snake.bin"
end_incbin_snake:
EndBlock3200:

