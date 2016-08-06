;##############################################################################
;##               Introducao a Arquitetura de Computadores                   ##
;##                                                                          ##
;## Projeto - TRON                                                           ##
;## 																		 ##
;## Grupo - 17															     ##
;## Nome - Alice Dourado   (81205)                                           ##
;## Nome - Andre Mendonca  (82304)                                           ##
;## Nome - Goncalo Ribeiro (82303)                                           ##
;##                                                                          ##
;## Data - 05/12/2014                                                        ##
;##############################################################################
	  
	;***************************************************************;
	; 			ZONA I: Definicao de constantes						;
	;         			Pseudo-instrucao : EQU						;
	;***************************************************************;

;===========================================================
;				Valor inicial da pilha 
;===========================================================
SP_INICIAL      EQU     FDFFh

;===========================================================
;				Interrupcoes do programa 
;===========================================================
INT_MASK_ADDR   EQU     FFFAh
INT_MASK		EQU		1000101010000011b

;===========================================================
;					Placa de Texto
;===========================================================
IO_WRITE        EQU     FFFEh
IO_CURSOR       EQU     FFFCh
IO_DISPLAY      EQU     FFF0h
INICIA_CURSOR   EQU     FFFFh

;===========================================================
;					Temporizador
;===========================================================
TIMER			EQU		FFF6h
CTIMER			EQU		FFF7h
TEMPO			EQU		1	  ;temporizador tem intervalo de tempo de uma decima

;===========================================================
;	    			LCD e Led's da placa
;===========================================================
LED				EQU		FFF8h 
WRITE_LCD		EQU		FFF5h 
POINT_LCD		EQU		FFF4h 

;===========================================================
;	Constantes referentes aos movimentos dos jogadores
;===========================================================
DIREITA		EQU		0000h
ESQUERDA	EQU		0001h
CIMA		EQU		0002h
BAIXO		EQU		0003h

;===========================================================
;				Definicao de coordenadas
;===========================================================
coord_fim		EQU		174Fh	;Define o ultimo ponto da janela-------->(23,79)
ultima_col		EQU		004Fh	;Define a ultima coluna da janela------->(0,79)

COORD_STR1		EQU		0B20h  	;String "Bem-vindo ao TRON"------------->(12,32)
COORD_STR2		EQU		0C1Ch  	;String "Pressione I1 para comecar"----->(13,28) 

COORD_STR3		EQU		0A1Ah	;String "Fim do jogo"------------------->(12,26)    
COORD_STR4		EQU		0C1Ah	;String "Pressione I1 para recomecar"--->(13,26) 

COORD_STR5		EQU		0B1Ah	;String "J1 ganhou"|"J2 ganhou"|"Empate"-(11,26)
COORD_STRVAZIA1	EQU		091Ah	;String vazia "   " -------------------->(14,26)
COORD_STRVAZIA2	EQU		0D1Ah	;String vazia "   " -------------------->(14,26)

sup_esq			EQU		010Fh	;Canto superior esquerdo da moldura------>(1,15)
sup_dir			EQU		0140h	;Canto superior direito da moldura------->(1,64)
inf_esq			EQU		160Fh	;Canto inferior esquerdo da moldura----->(22,15)
inf_dir			EQU		1640h	;Canto inferior direito da moldura------>(22,64)
inf_esq_aux		EQU		150Fh	;(21,15)

coord_x_inicial	EQU		0C18h	;Define a posicao inicial do jogador 1-->(12,24)
								;Coordenadas na moldura criada----------->(8,10)
								
coord_Y_inicial EQU		0C38h	;Define a posicao inicial do jogador 2-->(12,56)
								;Coordenadas na moldura criada---------->(40,10)

LCD_MASK		EQU		8000h ;Liga e aponta para a primeira posicao do LCD
Limpa_LCD		EQU		8020h
coord_LDC1 		EQU		800Bh
coord_LDC2		EQU		8014h
coord_LDC3		EQU		801Eh

FIM_TEXTO       EQU '@'
espaco			EQU	' '
D_mais			EQU	'+'
D_vert			EQU '|'
D_hori			EQU '-'
car_x			EQU 'X'
car_#			EQU '#'

	;***************************************************************;
	; 			ZONA II: Definicao de interrupcoes					;
	;***************************************************************;
	
				ORIG    FE00h	
INT_0			WORD	X_esq	
INT_1           WORD    Start
				ORIG	FE07h
INT_7			WORD	#_esq
				ORIG    FE09h	
INT_9			WORD	#_dir
				ORIG    FE0Bh	
INT_B			WORD	X_dir						
				ORIG	FE0Fh
INT_15			WORD	temporizador

	;*******************************************************************;
	; 			ZONA III: Definicao de variaveis						;
	;          	Pseudo-instrucoes : WORD - palavra (16 bits)			;
	;                              	STR  - sequencia de caracteres.		;
	;*******************************************************************;
                ORIG    8000h
VarTexto1       STR		'Bem-vindo ao TRON',FIM_TEXTO
VarTexto2		STR		'Pressione I1 para comecar',FIM_TEXTO
lcd_cadeia		STR		'TEMPO MAX: 0000sJ1: 00    J2: 00'
VarTexto3		STR		'         Fim do jogo         ',FIM_TEXTO
VarTexto4		STR		' Pressione I1 para recomecar ',FIM_TEXTO
VarTexto5		STR		'       Jogador 1 ganhou      ',FIM_TEXTO
VarTexto6		STR		'       Jogador 2 ganhou      ',FIM_TEXTO
VarTexto7		STR		'            Empate           ',FIM_TEXTO
VarTexto8		STR		'                             ',FIM_TEXTO
Game_ON			WORD	0
Contador        WORD    0000h
variavel		WORD	0000h
direcao_X		WORD	DIREITA
direcao_#		WORD	ESQUERDA	
velocidade		WORD	0007h
coord_x			WORD	0C18h   ;Define a coordenada do jogador 1------->(12,24) 
coord_#			WORD	0C38h	;Define a coordenada do jogador 2------->(12,56)
Next_x_dir		WORD	0
Next_x_esq		WORD	0
Next_Y_dir		WORD	0
Next_Y_esq		WORD	0
direcao			WORD	0
Next_esq		WORD	0
Next_dir		WORD	0
loser_x			WORD	0
loser_y			WORD	0
tempo_max		WORD 	0
J1				WORD	0
J2				WORD	0

coord_anterior	TAB		1096 ;Area de jogo incluindo moldura menos 
							 ;os caracteres '+' (50*22-4 = 1096)

;****************************************************************************;
; ZONA IV: 	Codigo															 ;
;           Conjunto de instrucoes Assembly, ordenadas de forma a realizar	 ;
;           as funcoes pretendidas											 ;
;****************************************************************************;

			ORIG	0000h
			JMP		Inicio
			
;===========================================================
; temporizador: Rotina de interrupcao 15
;               Entradas:  --
;               Saidas:   
;               Efeitos: coloca o valor 0 na variavel
;===========================================================
temporizador:	CALL 	Rotina_temp				
				MOV		M[variavel], R0				
				RTI
				
;===========================================================
; Rotina_temp: Rotina que inicia o temporizador
;              Entradas: 
;              Saidas:   
;              Efeitos: 
;===========================================================
Rotina_temp:MOV 	R5, TEMPO
			MOV		M[TIMER], R5
			MOV		R5, 1
			MOV 	M[CTIMER], R5
			RET
			
;=================================================================
; espera: Rotina que espea ate que o temporizador mude a variavel
;         Entradas: 
;         Saidas:   
;         Efeitos: espera 1 decima de segundo
;=================================================================
espera:		CMP		M[variavel], R0
			BR.NZ	espera
			INC		M[variavel]
			RET
			
;=========================================================================
;
; Contas: Rotina que calcula os segundos em decimal e escreve no display
;		  Entradas:---          
;         Saidas:---    
;		  Efeitos: faz divisoes para obter os algarismos 
;				   em decimal e escreve no display R2, R3 e R1
;				   (o R4 representa decimos por isso nao e usado)
;
;=========================================================================
Contas:		DSI
			INC		M[Contador];em decimos de segundo
			MOV		R1, M[Contador]
			MOV		R2, 100d
			MOV		R3,	10d
			MOV		R4, R3
			DIV		R1, R2
			DIV		R1, R3
			DIV		R2,	R4
			
			MOV		R6, IO_DISPLAY
			MOV		M[R6], R2
			INC 	R6
			MOV		M[R6], R3
			INC		R6
			MOV		M[R6], R1				
			ENI
			RET
			
;===========================================================
; Start: Rotina de interrupcao 1
;        Entradas:--
;        Saidas:--
;        Efeitos: incrementa a variavel Game_ON
;===========================================================
Start:		INC		M[Game_ON]
			RTI
			
;===========================================================
; X_esq: Rotina de interrupcao 0
;        Entradas: --
;        Saidas: --
;        Efeitos: incrementa a variavel Next_x_esq
;===========================================================
X_esq:		INC		M[Next_x_esq]
			RTI
			
;===========================================================
; X_dir: Rotina de interrupcao B
;        Entradas: --
;        Saidas: --
;        Efeitos: incrementa a variavel Next_x_dir
;===========================================================
X_dir:		INC		M[Next_x_dir]
			RTI
			
;===========================================================
; #_esq: Rotina de interrupcao 7
;        Entradas: --
;        Saidas: --
;        Efeitos: incrementa a variavel Next_Y_esq
;===========================================================
#_esq:		INC		M[Next_Y_esq]
			RTI
			
;===========================================================
; #_dir: Rotina de interrupcao 9
;        Entradas:  --
;        Saidas:   --
;        Efeitos: incrementa a variavel Next_Y_dir
;===========================================================
#_dir:		INC		M[Next_Y_dir]
			RTI
			
;=====================================================================
; Esc_lcd: rotina que escreve uma string no LCD
;          Entradas:  R2, R1
;          Saidas:   --
;          Efeitos: escreve no LCD a cadeia em R1 nas coordenadas R2
;=====================================================================
Esc_lcd:	MOV		M[POINT_LCD], R2 
			MOV		R3, M[R1]
			MOV		M[WRITE_LCD], R3
			INC		R1
			INC		R2
			CMP		R2,Limpa_LCD    ;acaba a escrita quando chega ao fim do LCD
			BR.Z	Fim_lcd
			BR		Esc_lcd
Fim_lcd:	RET			

;================================================================
; Escreve: Rotina que escreve na janela de texto
;          Entradas:  R3, R1
;          Saidas:   --
;          Efeitos: escreve a string em R1 nas coordenadas em R3
;================================================================
Escreve:	MOV		M[IO_CURSOR], R3
			MOV		R2, M[R1]
			CMP		R2, FIM_TEXTO
			BR.Z	Fim_esc
			MOV		M[IO_WRITE], R2
			INC		R1
			INC		R3
			BR		Escreve
Fim_esc:	RET

;===========================================================
; cursor_on: ativa o cursor
;            Entradas:  --
;            Saidas:   --
;            Efeitos: 
;===========================================================
cursor_on:	PUSH	R1
			MOV		R1, INICIA_CURSOR
			MOV		M[IO_CURSOR], R1
			POP     R1
			RET
			
;============================================================================
; Limpar: Rotina que limpa a janela de texto
;               Entradas:  --
;               Saidas:   --
;               Efeitos: escreve ' ' em todas as posicoes da janela de texto
;============================================================================
Limpar:		PUSH	R1
			PUSH	R2
			PUSH	R3
			MOV		R2, R0
			MOV		R3, ultima_col
			MOV		R1, espaco
l:			MOV		M[IO_CURSOR], R2
			MOV		M[IO_WRITE], R1
			CMP		R2, coord_fim
			BR.Z	fim_l
			CMP		R2, R3
			BR.Z	salta_linha 
			INC		R2
			BR		l
salta_linha:ADD		R3, 0100h
			ADD		R2, 0100h
			AND		R2, FF00h
			BR		l
fim_l:		POP		R3
			POP		R2
			POP		R1
			RET

;===========================================================
; sup_inf e esq_dir: subrotinas da Moldura
;               Entradas:  --
;               Saidas:   R5, R6
;               Efeitos: alteram coordenadas nos registos
;===========================================================	
sup_inf:	MOV		R5, inf_esq
			MOV		R6, inf_dir
			RET
esq_dir:	MOV		R5, sup_dir
			MOV		R6, inf_dir
			SUB		R6, 0100h
			RET
			
;===========================================================
; Moldura: controi moldura 
;               Entradas:  R7
;               Saidas:   R7
;               Efeitos: faz moldura e posiciona jogadores
;===========================================================
Moldura:	CALL	Limpar
			MOV		R1, D_mais ;'+'
			MOV		R2, D_hori ;'-'
			MOV		R3, D_vert ;'|'
			MOV		R5, sup_esq
			MOV		R6, sup_dir
			
horizontal:	MOV		M[IO_CURSOR], R5
			MOV		M[IO_WRITE], R1
			
tracos:		INC		R5
			MOV		M[IO_CURSOR], R5
			MOV		M[R7], R5   ; mete coordenada na tabela de colisoes
			INC		R7
			MOV		M[IO_WRITE], R2
			CMP		R5, R6
			BR.NZ	tracos
			MOV		M[IO_WRITE],R1
			CMP		R5, sup_dir
			CALL.Z	sup_inf
			CMP		R6, R5
			BR.NZ	horizontal
			MOV		R5, sup_esq
			MOV		R6, inf_esq
			SUB		R6, 0100h
			
vertical:	ADD 	R5, 0100h
			MOV		M[IO_CURSOR], R5
			MOV		M[IO_WRITE], R3
			MOV		M[R7], R5
			INC		R7
			CMP		R5, R6
			BR.NZ	vertical
			CMP		R5, inf_esq_aux
			CALL.Z	esq_dir
			CMP		R5, R6
			BR.NZ	vertical
			
			MOV		R1, car_x
			MOV		R2, coord_x_inicial
			CALL	esc_car
			MOV		R1, car_#
			MOV		R2, coord_Y_inicial
			CALL	esc_car
			RET
;==================================================================
; esc_car: subrotina da Moldura
;               Entradas:  R2, R1
;               Saidas:   --
;               Efeitos: escreve o caracter em R1 na coordenada R2
;==================================================================
esc_car:	MOV		M[IO_CURSOR], R2
			MOV		M[R7], R2
			INC		R7
			MOV		M[IO_WRITE], R1
			RET
;================================================================
; move: move os jogadores
;               Entradas:  --
;               Saidas:   --
;               Efeitos: muda variaveis e chama a subrotina mexe
;================================================================
move:		DSI
			MOV		R1, ESQUERDA
			MOV		R2, CIMA
			MOV		R3, BAIXO
			MOV		R5, M[coord_x]
			MOV		R6, car_x
			MOV		R4, M[direcao_X]
			MOV		M[direcao], R4
			MOV		R4, M[Next_x_dir]
			MOV		M[Next_dir], R4
			MOV		R4, M[Next_x_esq]
			MOV		M[Next_esq], R4
			CALL	mexe
			MOV		M[coord_x], R5
			MOV		M[Next_x_dir], R0
			MOV		M[Next_x_esq], R0
			MOV		R4, M[direcao]
			MOV		M[direcao_X], R4
			
			MOV		R5, M[coord_#]
			MOV		R6, car_#
			MOV		R4, M[direcao_#]
			MOV		M[direcao], R4
			MOV		R4, M[Next_Y_dir]
			MOV		M[Next_dir], R4
			MOV		R4, M[Next_Y_esq]
			MOV		M[Next_esq], R4
			CALL	mexe
			MOV		M[coord_#], R5
			MOV		M[Next_Y_dir], R0
			MOV		M[Next_Y_esq], R0
			MOV		R4, M[direcao]
			MOV		M[direcao_#], R4
			RET
			
;===============================================================================
; mexe: subrotina da move que verifica colisoes e escreve o caracter do jogador
;            Entradas:  R1, R2, R3, R5, R6, R7          
;            Saidas:   R7
;            Efeitos: calcula a direcao, verifica se ha colisoes
;                     se houver vai-se para o final, se nao realiza-se 
;                     o movimento do jogador
;===============================================================================
mexe:		CMP		M[direcao], R1
			BR.Z	da_esq
			CMP		M[direcao], R2
			BR.Z	de_cima
			CMP		M[direcao], R3
			BR.Z	de_baixo
da_dir:		CMP		M[Next_dir], R0
			JMP.NZ	vai_pa_baixo
			CMP		M[Next_esq], R0
			JMP.NZ	vai_pa_cima
			JMP		vai_pa_dir
da_esq:		CMP		M[Next_dir], R0
			JMP.NZ	vai_pa_cima
			CMP		M[Next_esq], R0
			JMP.NZ	vai_pa_baixo
			JMP		vai_pa_esq
de_cima:	CMP		M[Next_dir], R0
			JMP.NZ	vai_pa_dir
			CMP		M[Next_esq], R0
			JMP.NZ	vai_pa_esq
			JMP		vai_pa_cima
de_baixo:	CMP		M[Next_dir], R0
			JMP.NZ	vai_pa_esq
			CMP		M[Next_esq], R0
			JMP.NZ	vai_pa_dir
			JMP		vai_pa_baixo

vai_pa_baixo:	MOV		M[direcao], R3
				ADD		R5, 100h
				BR		fim_mov
vai_pa_cima:	MOV		M[direcao], R2
				SUB		R5, 100h
				BR 		fim_mov
vai_pa_esq:		MOV		M[direcao], R1
				DEC		R5 
				BR 		fim_mov
vai_pa_dir:		MOV		M[direcao], R0
				INC		R5	
fim_mov:		MOV		M[IO_CURSOR], R5
				JMP		verifica_colisoes
cont_mov:		CMP		M[loser_x], R0
				JMP.NZ	final
				MOV		M[R7], R5
				INC		R7				
				MOV		M[IO_WRITE], R6
				RET
;verifica-se se a coord do proximo movimento esta na tabela das coord anteriores
verifica_colisoes:	MOV		R4, coord_anterior
ciclo_colisoes:		CMP		M[R4], R5     
					JMP.Z	ha_colisao
					INC		R4
					CMP		R4, R7
					BR.Z	cont_mov 
					BR 		ciclo_colisoes
;se ha colisoes incrementa-se loser_x ou loser_y para indicar quem perde
; se for empate aumenta-se ambas
ha_colisao:			CMP		R6, car_x
					BR.Z    x_perdeu
					INC		M[loser_y]
					CMP		R5, M[coord_x]
					JMP.NZ	final
					INC		M[loser_x]
					JMP		final
x_perdeu:			INC		M[loser_x]
					RET
			

;=================================================================
; muda_nivel: rotina que muda o nivel do jogo(aumenta a rapidez)
;                Entradas:  --      
;                Saidas:   --
;                Efeitos: se o tempo estiver nos 10,20,40 ou 60s
;                         diminui M[velocidade] e acende 4 LEDs
;                                                
;==================================================================
muda_nivel:	MOV		R1, M[Contador]
			CMP		R1, 100d
			BR.Z	nivel_2
			CMP		R1, 200d
			BR.Z	nivel_3
			CMP		R1, 400d
			BR.Z	nivel_4
			CMP		R1, 600d
			BR.Z	nivel_5
			RET
nivel_2:	MOV		R2, 5h
			MOV		M[velocidade], R2
			MOV    	R1, Fh
			BR		fim_nivel
nivel_3:	MOV		R2, 3h
			MOV		M[velocidade], R2
			MOV    	R1, FFh
			BR		fim_nivel		
nivel_4:	MOV		R2, 2h
			MOV		M[velocidade], R2
			MOV    	R1, FFFh
			BR		fim_nivel
nivel_5:	MOV		R2, 1h
			MOV		M[velocidade], R2
			MOV    	R1, FFFFh
fim_nivel:	MOV		M[LED], R1
			RET
			
;============================================================================
; update_LCD: rotina que faz update do tempo maximo no LCD
;               Entradas:  R1
;               Saidas:   --
;               Efeitos: calcula o valor de cada algarismo de R1 em decimal, 
;                        converte para ASCII e escreve no LCD              
;============================================================================
update_LCD: MOV		R3, 10d
			DIV		R1, R3
			MOV		R2, 100d
			MOV		R3, 10d
			MOV		R4, R3
			DIV		R1, R2
			DIV		R1, R3
			DIV		R2, R4
			ADD		R1, 48d
			ADD		R3, 48d
			ADD		R2, 48d
			ADD		R4, 48d
		
			MOV		R6, coord_LDC1
			MOV		M[POINT_LCD], R6
			MOV		M[WRITE_LCD], R1
			CALL	next_nu
			MOV		M[WRITE_LCD], R3
			CALL	next_nu
score:		MOV		M[WRITE_LCD], R2
			CALL	next_nu
			MOV		M[WRITE_LCD], R4
			RET
			
;=====================================================================
; next_nu: subrotina de update_LCD que incrementa o pointer do LCD
;               Entradas:  R6
;               Saidas:   --
;               Efeitos: 
;=====================================================================			
next_nu:	INC		R6
			MOV		M[POINT_LCD], R6
			RET
;===============================================================================
; substitui_tempomax, nao_substitui_tempomax: atualiza ou mantem o tempo maximo 
;                                               para depois escrever no LCD
;===============================================================================
substitui_tempomax:		MOV		M[R5],R1
						JMP		CONTINUA_LCD
nao_substitui_tempomax:	MOV		R1, M[R5]
						JMP		CONTINUA_LCD
			
;======================================================================
; winner_x e winner_y: escreve no LCD mais um ponto para o vencedor
;======================================================================			
winner_x:	INC		M[J1]
			MOV		R1, VarTexto5
			MOV		R3, COORD_STR5
			CALL	Escreve
			MOV		R2, M[J1]
			MOV		R6, coord_LDC2
hex_dec:	MOV		M[POINT_LCD], R6
			MOV		R4,10d
			DIV		R2, R4
			ADD		R2, 48d
			ADD		R4, 48d
			JMP		score
winner_y:	INC		M[J2]
			MOV		R1, VarTexto6
			MOV		R3, COORD_STR5
			CALL	Escreve
			MOV		R2, M[J2]
			MOV		R6, coord_LDC3
			BR		hex_dec
			
;===================================================================
;wait_move: ve se passou a quantidade de tempo definida 
;           pela variavel velocidade, se sim continua o movimento,
;           se nao volta para o ciclo do jogo
;===================================================================
wait_move:	MOV		R1, M[Contador] 
			MOV		R2, M[velocidade]
			DIV		R1, R2
			CMP		R2, R0	
			ENI
			JMP.NZ	ciclo
			JMP		mover			

;==========================================================================
; escreve_fim: rotina que escreve na janela de texto quando o jogo acaba
;              Entradas: --       
;              Saidas:   --
;              Efeitos: 
;==========================================================================			
escreve_fim:	MOV		R1, VarTexto3
				MOV		R3, COORD_STR3
				CALL	Escreve
				MOV		R1, VarTexto4
				MOV		R3, COORD_STR4
				CALL	Escreve
				MOV		R1, VarTexto8
				MOV		R3, COORD_STRVAZIA1
				CALL	Escreve
				MOV		R1, VarTexto8
				MOV		R3, COORD_STRVAZIA2
				CALL	Escreve
				MOV		R1, VarTexto7
				MOV		R3, COORD_STR5
				CALL	Escreve
				RET
				
;===============================================================================
; INICIO DO PROGRAMA PRINCIPAL
;===============================================================================			
		
Inicio:			MOV     R5, SP_INICIAL
				MOV     SP, R5	
				MOV     R5, INT_MASK
				MOV     M[INT_MASK_ADDR], R5
				CALL	cursor_on
				ENI
				CALL	Limpar
			
				MOV		R1, VarTexto1
				MOV		R3, COORD_STR1
				Call	Escreve
				MOV		R1, VarTexto2
				MOV		R3, COORD_STR2
				Call	Escreve
				MOV		R2, LCD_MASK
				MOV		R1, lcd_cadeia
				CALL	Esc_lcd			
on:				CMP		M[Game_ON], R0;ciclo enquanto se espera pela int_1
				BR.Z	on
				MOV		R7, coord_anterior
				CALL	Moldura
				MOV		M[LED], R0
				MOV		R1, coord_x_inicial
				MOV		M[coord_x], R1
				MOV		R1, coord_Y_inicial
				MOV		M[coord_#], R1
				CALL 	Rotina_temp		
				INC		M[variavel]				
ciclo:			CALL    Contas
				CALL	espera
				DSI
				CALL	muda_nivel
				JMP		wait_move
mover:			CALL	move
				ENI
				BR		ciclo
			
final:			MOV     M[CTIMER], R0
				DSI
				MOV		R1, M[Contador]
				MOV		R5, tempo_max
				CMP		R1, M[R5]
				JMP.P	substitui_tempomax
				JMP		nao_substitui_tempomax
CONTINUA_LCD:	CALL	update_LCD
				CALL	escreve_fim
				CMP		M[loser_x], R0
				CALL.Z	winner_x
				CMP		M[loser_y], R0
				CALL.Z	winner_y
;por os valores originais em variaveis para recomecar o jogo
				MOV 	M[Game_ON], R0
				MOV		M[Contador], R0
				MOV		R1, DIREITA
				MOV		M[direcao_X], R1
				MOV		R1, ESQUERDA
				MOV		M[direcao_#], R1
				MOV		M[loser_y], R0
				MOV		M[loser_x], R0
				MOV		M[Next_x_dir], R0
				MOV		M[Next_x_esq], R0
				MOV		M[Next_Y_dir], R0
				MOV		M[Next_Y_esq], R0
				MOV		R1,	7h
				MOV		M[velocidade], R1
				ENI
				JMP		on
			
